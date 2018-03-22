module Hpr
  module Utils
    extend self

    def run_cmd(*commands, echo = true)
      commands.each_with_object([] of String) do |command, obj|
        Hpr.log.debug "$ #{command}" if echo
        obj << `#{command}`.strip
      end
    end

    def repository_path(name : String)
      File.join(Hpr.config.repository_path, name)
    end

    def repository_path?(name : String) : String?
      path = repository_path(name)
      Dir.exists?(path) ? path : nil
    end

    def repository_info(name : String)
      Dir.cd repository_path(name)
      url, mirror_url, latest_version = Utils.run_cmd "git remote get-url --push origin",
                                                      "git remote get-url --push mirror",
                                                      "git describe --abbrev=0 --tags 2>/dev/null",
                                                      echo: false
      {
        "name" => name,
        "url" => url,
        "mirror_url" => mirror_url,
        "latest_version" => latest_version,
      }
    end

    def tryable(max_connect = 3, verbose = false, &block)
      count = 1
      loop do
        begin
          Hpr.log.debug "try ... #{count}" if verbose
          break if count > max_connect
          return yield
          break
        rescue e : Exception
          Hpr.log.debug " * #{e.class}: #{e.message}"
          count += 1
          sleep 1
        end
      end
    end
  end
end
