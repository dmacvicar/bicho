# Colorizes the output of the standard library logger, depending on the logger level:
# To adjust the colors, look at Logger::Colors::SCHEMA and Logger::Colors::constants

require 'logger'

# Utility class to color output.
class Logger
  module Colors
    VERSION = '1.0.0'.freeze

    NOTHING      = '0;0'.freeze
    BLACK        = '0;30'.freeze
    RED          = '0;31'.freeze
    GREEN        = '0;32'.freeze
    BROWN        = '0;33'.freeze
    BLUE         = '0;34'.freeze
    PURPLE       = '0;35'.freeze
    CYAN         = '0;36'.freeze
    LIGHT_GRAY   = '0;37'.freeze
    DARK_GRAY    = '1;30'.freeze
    LIGHT_RED    = '1;31'.freeze
    LIGHT_GREEN  = '1;32'.freeze
    YELLOW       = '1;33'.freeze
    LIGHT_BLUE   = '1;34'.freeze
    LIGHT_PURPLE = '1;35'.freeze
    LIGHT_CYAN   = '1;36'.freeze
    WHITE        = '1;37'.freeze

    SCHEMA = {
      STDOUT => %w(nothing green brown red purple cyan),
      STDERR => %w(nothing green yellow light_red light_purple light_cyan)
    }.freeze
  end

  alias format_message_colorless format_message

  def format_message(level, *args)
    if Logger::Colors::SCHEMA[@logdev.dev]
      color = begin
        Logger::Colors.const_get \
          Logger::Colors::SCHEMA[@logdev.dev][Logger.const_get(level.sub('ANY', 'UNKNOWN'))].to_s.upcase
      rescue NameError
        '0;0'
      end
      "\e[#{color}m#{format_message_colorless(level, *args)}\e[0;0m"
    else
      format_message_colorless(level, *args)
    end
  end
end

# J-_-L
