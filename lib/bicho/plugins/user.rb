# frozen_string_literal: true

require 'yaml'

module Bicho
  module Plugins
    # Plugin to get preferences from the user home directory
    # .config/bicho/config.yml
    #
    class User
      DEFAULT_CONFIG_PATH = File.join(ENV['HOME'], '.config', 'bicho', 'config.yml') unless defined? DEFAULT_CONFIG_PATH

      class << self
        attr_writer :config_path
      end

      def self.config_path
        @config_path ||= DEFAULT_CONFIG_PATH
      end

      def initialize
        @config = {}
        @config = YAML.load_file(Bicho::Plugins::User.config_path) if File.exist?(Bicho::Plugins::User.config_path)
      end

      def default_site_url_hook(logger)
        if @config.key?('default')
          ret = @config['default']
          logger.debug "Default url set to '#{ret}'"
          ret
        else
          logger.warn 'Use .config/bicho/config.yaml to setup a default bugzilla site'
        end
      end

      def transform_site_url_hook(url, logger)
        if @config['aliases']&.key?(url.to_s)
          ret = @config['aliases'][url.to_s]
          logger.debug "Transformed '#{url}' to '#{ret}'"
          ret
        else
          url
        end
      end
    end
  end
end
