require 'jbuilder'
require 'jbuilder/json_api/version'

module JsonAPI
  # Returns a valid-formatted JSON which follows JSON-API specifications:
  # http://jsonapi.org/
  #
  # ==== Arguments
  # * +resources+ - list of resources to render (may be even one or nil);
  # * +errors+ - array of hashes in the below format:
  #     [{ status: 422, detail: 'This error occurs because...' }, {...}]
  # * +meta+ - a hash representing any meta (additional) information.
  #
  # ==== Options
  # Any information can be passed as +options+ argument; resources' class methods
  # +json_api_attrs+, +json_api_relations+ and +json_api_meta+
  # will be invoked with this argument.
  #
  def api_format! (resources = nil, errors = nil, meta = nil, options = {})
    begin
      # Firstly, print meta
      # http://jsonapi.org/format/#document-meta
      #
      if meta && !meta.empty?
        meta meta
      end

      # Secondly, take care of errors. If there are any,
      # no 'data' section should be represented.
      # http://jsonapi.org/format/#document-top-level
      #
      # Read more at
      # http://jsonapi.org/format/#errors
      #
      if errors && !errors.empty?
        ignore_nil! true
        errors errors do |error|
          id     error[:id]
          status error[:status]
          detail error[:detail]
          code   error[:code]
          title  error[:title]

          if error[:source]
            source do
              pointer   error[:source][:pointer]
              paramater error[:source][:parameter]
            end
          end

          if error[:links]
            links do
              about error[:links][:about]
            end
          end
        end
        return self
      end

      resources = [*resources]

      # http://jsonapi.org/format/#document-links
      #
      if @context
        links do
          set! 'self', @context.request.path
        end
      end

      data do
        resources.blank? ? array! : _api_resource_objects(resources, options)
      end

      included = []
      resources.each do |resource|
        next unless resource.respond_to?'json_api_relations'
        resource.json_api_relations(options).each do |relationship|
          included += [*(resource.send(relationship))]
        end
      end
      included.uniq!

      included do
        _api_resource_objects(included, options, resources) unless included.blank?
      end

      self
    rescue Exception => e
      @attributes = {}
      message = Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.3.0') ? e.original_message : e.message
      return api_format! nil, [{ status: 500, title: e.class.to_s, detail: message }]
    end
  end

  private

  # Formats a resources array properly
  # http://jsonapi.org/format/#document-resource-objects
  #
  def _api_resource_objects (resources, options, parent_resources = nil)
    resources.each do |resource|
      child! do
        type resource.class.name.demodulize.to_s.downcase
        id   resource.id

        # http://jsonapi.org/format/#document-resource-object-attributes
        #
        if resource.respond_to?'json_api_attrs'
          attributes do
            resource.json_api_attrs(options).each do |attribute|
              set! attribute, resource.send(attribute)
            end
          end
        end

        # http://jsonapi.org/format/#document-resource-object-relationships
        #
        if resource.respond_to?'json_api_relations'
          unless resource.json_api_relations(options).blank?
            relationships do
              resource.json_api_relations(options).each do |relationship|
                set! relationship do
                  if @context
                    links do
                      related @context.send("#{ relationship.pluralize }_path")
                      # TODO add a link to the relationship itself
                    end
                  end

                  data do
                    [*(resource.send(relationship))].each do |relationship_instance|
                      # Relationships shouldn't ever link to the parent resource
                      #
                      next if !parent_resources.nil? && parent_resources.include?(relationship_instance)
                      child! do
                        type relationship_instance.class.name.demodulize.to_s.downcase
                        id relationship_instance.id
                      end
                    end
                  end
                end
              end
            end
          end
        end

        if resource.respond_to?'json_api_meta'
          # We don't want to see 'meta': null
          ignore_nil! true
          meta resource.json_api_meta(options)
          ignore_nil! @ignore_nil
        end

        if @context
          links do
            set! 'self', @context.send("#{ resource.class.name.demodulize.to_s.downcase }_path", resource)
          end
        end
      end
    end
  end
end

Jbuilder.include JsonAPI
