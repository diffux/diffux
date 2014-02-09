if ENV['PHANTOMJS_PATH']
  module Phantomjs
    class HerokuPlatform < Platform
      class << self
        def phantomjs_path
          ENV['PHANTOMJS_PATH']
        end

        def useable?
          File.exist?(ENV['PHANTOMJS_PATH'])
        end

        def ensure_installed!
          # noop
        end
      end
    end
  end

  Phantomjs.available_platforms.unshift(Phantomjs::HerokuPlatform)
end
