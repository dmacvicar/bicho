$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'test/unit'
require 'bicho'

if ENV['DEBUG']
  Bicho::Logging.logger = Logger.new(STDERR)
  Bicho::Logging.logger.level = Logger::DEBUG
end
