require 'jbuilder'
require 'jbuilder/json_api/version'

module JsonAPI
  # Returns a valid-formatted JSON which follows JSON-API specifications:
  # http://jsonapi.org/
  #
  # Arguments:
  #   :resources: - list of resources to render (may be even one or nil)
  #   :errors: - array of errors in below format:
  #     [{ status: 422, detail: 'This error occurs because...' }, {...}]
  #
  # Options:
  #   :access_level: - access level, e.g. nil, :user, :admin
  #   :meta: - a hash representing meta (additional) information
  #
  def api_format! (resources = nil, errors = nil, options = {})
    options.merge access_level: nil
    options.merge meta: nil

    # Firstly, print meta
    # http://jsonapi.org/format/#document-meta
    #
    if options[:meta] && !options[:meta].empty?
      meta options[:meta]
    end

    # Secondly, take care of errors. If there are any,
    # no 'data' section should be represented.
    # http://jsonapi.org/format/#document-top-level
    #
    # Read more at
    # http://jsonapi.org/format/#errors
    #
    if errors && !errors.empty?
      ignore_nil! (@ignore_nil.nil? ? true : @ignore_nil)
      errors errors do |error|
        id     error[:id]
        status error[:status]
        detail error[:detail]
        code   error[:code]
        title  error[:title]

        source do
          pointer   error[:pointer]
          paramater error[:parameter]
        end

        links do
          about error[:about]
        end
      end
      return self
    end

    resources = ::Kernel::Array resources

    # http://jsonapi.org/format/#document-links
    #
    links do
      begin
        set! 'self', @context.request.path
      rescue
        # No @context given, cannot find path
      end
    end

    data do
      resources.blank? ? array! : _api_resource_objects(resources, options[:access_level])
    end

    included = []
    resources.each do |resource|
      next unless resource.respond_to?'json_api_relations'
      resource.json_api_relations(options[:access_level]).each do |relationship|
        included += ::Kernel::Array(resource.send(relationship))
      end
    end
    included.uniq!

    included do
      _api_resource_objects(included, options[:access_level], resources) unless included.blank?
    end

    self
  end

  private

  # Formats a resources array properly
  # http://jsonapi.org/format/#document-resource-objects
  #
  def _api_resource_objects (resources, access_level, parent_resources = nil)
    resources.each do |resource|
      child! do
        type resource.class.name.demodulize.to_s.downcase
        id   resource.id

        # http://jsonapi.org/format/#document-resource-object-attributes
        #
        if resource.respond_to?'json_api_attrs'
          attributes do
            resource.json_api_attrs(access_level).each do |attribute|
              set! attribute, resource.send(attribute)
            end
          end
        end

        # http://jsonapi.org/format/#document-resource-object-relationships
        #
        if resource.respond_to?'json_api_relations'
          unless resource.json_api_relations(access_level).blank?
            relationships do
              resource.json_api_relations(access_level).each do |relationship|
                set! relationship do
                  links do
                    begin
                      related @context.send("#{ relationship.pluralize }_path")
                    rescue
                      # No @context given, cannot find path
                    end
                    # TODO add a link to the relationship itself
                  end

                  data do
                    ::Kernel::Array(resource.send(relationship)).each do |relationship_instance|
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

        links do
          begin
            set! 'self', @context.send("#{ resource.class.name.demodulize.to_s.downcase }_path", resource)
          rescue
            # No @context given, cannot find path
          end
        end
      end
    end
  end
end

Jbuilder.include JsonAPI
