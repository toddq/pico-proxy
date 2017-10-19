require 'yaml'

CONFIG_FILE = 'config/config.yml'

module Config
    @config = YAML.load_file(CONFIG_FILE)

    def self.config
        @config
    end

    def self.write_cookies(cookies)
        @config['cookies'] = cookies
        puts "writing cookies to config: #{@config}"
        File.write(CONFIG_FILE, @config.to_yaml)
    end
end
