module Hpr::API::Repositories
  # List all repositories
  class List < Salt::App
    def call(env)
      names = CLIENT.list_repositories
      repositories = names.each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name) if Utils.repository_path?(name)
      end

      body = {
        total: repositories.size,
        data:  repositories,
      }.to_json

      {200, {"Content-Type" => "application/json"}, [body]}
    end
  end

  # Get a repository by given name
  class Show < Salt::App
    def call(env)
      name = env.params["name"]
      if Utils.repository_path?(name)
        if Utils.repository_cloning?(name)
          status_code = 202
          body = {
            message: "Repositoy is cloning, wait a moment.",
          }
        else
          status_code = 200
          body = Utils.repository_info(name)
        end
      else
        status_code = 404
        body = {
          message: "Not found repository: #{name}",
        }
      end

      {status_code, {"Content-Type" => "application/json"}, [body.to_json]}
    end
  end

  # Create new repository
  class Create < Salt::App
    def call(env)
      begin
        url = env.params["url"]
        name = env.params["name"]?
        mirror_only = env.params["mirror_only"]? || "false"
        CLIENT.create_repository(
          url, name,
          mirror_only == "true"
        )
        body = true
        status_code = 201
      rescue e : Exception
        body = {
          message: e.message,
        }
        status_code = 400
      end

      {status_code, {"Content-Type" => "application/json"}, [body.to_json]}
    end
  end

  # Update a repository by given name
  class Update < Salt::App
    def call(env)
      CLIENT.update_repository(env.params["name"])
      {200, {"Content-Type" => "application/json"}, ["true"]}
    end
  end

  # Remove a repository by given name
  class Delete < Salt::App
    def call(env)
      CLIENT.delete_repository env.params["name"]
      {200, {"Content-Type" => "application/json"}, ["true"]}
    end
  end

  # Search repositories by name
  class Search < Salt::App
    def call(env)
      keyword = env.params["name"]
      repositories = CLIENT.search_repositories(keyword).each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name)
      end

      status_code = 200
      body = {
        total: repositories.size,
        data:  repositories,
      }

      {status_code, {"Content-Type" => "application/json"}, [body.to_json]}
    end
  end
end
