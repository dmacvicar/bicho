$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/mock'
Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)
require 'bicho'

if ENV['DEBUG']
  Bicho::Logging.logger = Logger.new(STDERR)
  Bicho::Logging.logger.level = Logger::DEBUG
end
