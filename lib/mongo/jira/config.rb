require 'openssl'
begin
  require 'base64'
rescue LoadError
  module Base64
    def decode64(str)
      str.unpack('m0').first
    end
    def encode64(bin)
      [bin].pack('m0')
    end
  end
end
require 'digest'

module Mongo
  module Jira
    class Config

      CFG_FILE="#{ENV['HOME']}/.mongo_jira.json"

      # check the config file
      #
      # @example Save to default location and specific location.
      #   Mongo::Jira::Config::check()
      #   Mongo::Jira::Config::check("/tmp/.jira.json")
      #
      # @param [ String ] filename The config file path. It defaults to "#{ENV['HOME']}/.mongo_jira.json"
      #
      # @return [ true, false ] If the config is ok.
      #
      # @since 0.0.1
      def self.check(filename=CFG_FILE)
        File::exists?(filename)
      end

      # save the config file
      #
      # @example write the config file
      #   Mongo::Jira::Config::check()
      #   Mongo::Jira::Config::check("/tmp/.jira.json")
      #
      # @param [ String ] filename The config file path. It defaults to "#{ENV['HOME']}/.mongo_jira.json"
      #
      # @return [ true, false ] If the config is ok.
      #
      # @since 0.0.1
      def self.save(config, filename)
        cpy = config.clone
        if config[:password]
          cpy[:password] = Mongo::Jira::Config::encrypt('password',cpy[:password])
        else
          cpy.delete(:password)
        end
        cpy[:context_path] ||= ''

        File.open(filename , 'w') {|f| f.write(JSON.pretty_generate(cpy)) }
      end

      def self.load(filename=CFG_FILE)
        Config.new(filename)
      end

      attr_accessor :filename , :config
      def initialize(file)
        raise ConfigException , "file not found #{file}" unless File::exists?(file)
        @filename=file
        @config = JSON.parse( IO.read(filename) )
        config.symbolize_keys!()
        config[:auth_type] = (config[:auth_type] || :basic).to_sym
        config[:context_path] = ''
        config[:password] = Mongo::Jira::Config::decrypt("password", config[:password]) if config[:password]
      end

      def save
        Mongo::Jira::Config::save(config,filename)
      end

      def password?
        config[:password]
      end

      def password=(pw)
        config[:password]=pw
      end

      def self.encrypt(key, value)
        cipher = OpenSSL::Cipher::Cipher.new("des3")
        cipher.encrypt # Call this before setting key or iv
        cipher.key = key * 10
        cipher.iv = '12345678'
        text = cipher.update(value)
        text << cipher.final
        Base64.encode64(text).chomp
      end

      def self.decrypt(key, data)
        cipher = OpenSSL::Cipher::Cipher.new("des3")
        cipher.decrypt
        cipher.key = key * 10
        cipher.iv = '12345678'
        plaintext = cipher.update(Base64.decode64(data))
        plaintext << cipher.final
      end

    end
    class ConfigException < StandardError; end
  end
end
