module DummyApp
  class Post
    attr_accessor :id
    attr_accessor :title
    attr_accessor :body
    attr_accessor :author
    attr_accessor :comments

    def json_api_attrs (access_lvl = nil)
      attrs = %w(id title)
      attrs << 'body' if access_lvl == :admin
      attrs
    end

    def json_api_relations (access_lvl = nil)
      attrs = %w(author)
      attrs << 'comments' if access_lvl == :admin
      attrs
    end
  end

  class User
    attr_accessor :id
    attr_accessor :name
    attr_accessor :comments

    def json_api_attrs (access_lvl = nil)
      %w(id name)
    end

    def json_api_relations (access_lvl = nil)
      %w(comments)
    end
  end

  class Comment
    attr_accessor :id
    attr_accessor :body
    attr_accessor :user
    attr_accessor :post

    def json_api_attrs (access_lvl = nil)
      %w(id body)
    end

    def json_api_relations (access_lvl = nil)
      %w(user post)
    end
  end
end