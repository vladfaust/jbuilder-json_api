require 'json'

describe JsonAPI do
  it 'has a version number' do
    expect(JsonAPI::VERSION).to_not be nil
  end

  describe 'api_format!' do
    DEBUG = false # Set it to true when want to just write JSONs to files, false enables testing itself

    def check (json, name)
      if DEBUG
        File.write "spec/jbuilder/examples/#{ name }.json", JSON.pretty_unparse(json)
      else
        expect(JSON.pretty_unparse(json)).to eq File.read("spec/jbuilder/examples/#{ name }.json")
      end
    end

    let (:resources) { create_list :post, 2, :with_author, :with_comments }

    let (:errors) do
      [
          {
              id: 1,       # Internal ID
              status: 404, # HTTP status
              title: 'Not found',
              detail: 'The requested resource cannot be found.',
              code: 112, # Some internal code
              source: {
                  pointer: 'http://posts_path'
              },
              links: {
                  about: 'https://en.wikipedia.org/wiki/HTTP_404'
              }
          },
          {
              id: 2,
              title: 'Another error'
          }
      ]
    end

    let (:meta) do
      {
          copyright: 'Vlad Faust',
          year: '2016',
          joke: {
              title: 'Not funny at all',
              body: 'A SQL query walks up to two tables in a restaurant and asks: "Mind if I join you?"'
          }
      }
    end

    it 'fetches resources' do
      json = JSON.parse(Jbuilder.new.api_format!(resources).target!)
      check json, 'resources'
    end

    it 'fetches resources w/ admin rights' do
      json = JSON.parse(Jbuilder.new.api_format!(resources, nil, nil, access_lvl: :admin).target!)
      check json, 'resources_admin'
    end

    it 'fetches resources w/ errors' do
      json = JSON.parse(Jbuilder.new.api_format!(resources, errors).target!)
      check json, 'resources_errors'
    end

    it 'fetches errors only' do
      json = JSON.parse(Jbuilder.new.api_format!(nil, errors).target!)
      check json, 'errors'
    end

    it 'fetches meta only' do
      json = JSON.parse(Jbuilder.new.api_format!(nil, nil, meta).target!)
      check json, 'meta'
    end

    it 'fetches errors w/ meta' do
      json = JSON.parse(Jbuilder.new.api_format!(nil, errors, meta).target!)
      check json, 'errors_meta'
    end

    it 'fetches resources w/ meta' do
      json = JSON.parse(Jbuilder.new.api_format!(resources, nil, meta).target!)
      check json, 'resources_meta'
    end

    it 'fetches resources w/ errors & meta' do
      json = JSON.parse(Jbuilder.new.api_format!(resources, errors, meta).target!)
      check json, 'resources_errors_meta'
    end

    it 'fetches internal errors' do
      json = JSON.parse(Jbuilder.new.api_format!(42, nil, meta).target!)
      check json, 'internal_errors'
    end
  end
end
