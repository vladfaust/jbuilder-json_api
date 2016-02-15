module DummyApp
  class Post
    attr_accessor :id
    attr_accessor :title
    attr_accessor :body
    attr_accessor :author
    attr_accessor :comments

    def json_api_attrs (options = {})
      attrs = %w(id title)
      attrs << 'body' if options[:access_lvl] == :admin
      attrs
    end

    def json_api_relations (options = {})
      attrs = %w(author)
      attrs << 'comments' if options[:access_lvl] == :admin
      attrs
    end

    def json_api_meta (options = {})
      { blah: "Just another meta info for post ##{ id }" } if options[:access_lvl] == :admin
    end
  end

  class User
    attr_accessor :id
    attr_accessor :name
    attr_accessor :comments

    def json_api_attrs (options = {})
      %w(id name)
    end

    def json_api_relations (options = {})
      %w(comments)
    end
  end

  class Comment
    attr_accessor :id
    attr_accessor :body
    attr_accessor :user
    attr_accessor :post

    def json_api_attrs (options = {})
      %w(id body)
    end

    def json_api_relations (options = {})
      %w(user post)
    end
  end
end