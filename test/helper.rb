# frozen_string_literal: true

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/mock'
require 'vcr'

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

def fixture(path)
  File.absolute_path(File.join(File.dirname(__FILE__), '..', 'test', 'fixtures', path))
end

VCR.configure do |config|
  config.cassette_library_dir = fixture('vcr')
  config.hook_into :webmock
end
