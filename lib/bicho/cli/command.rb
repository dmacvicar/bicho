#--
# Copyright (c) 2011 SUSE LINUX Products GmbH
#
# Author: Duncan Mac-Vicar P. <dmacvicar@suse.de>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'trollop'
require 'highline'

module Bicho
  module CLI
    # Bicho allows to easily add commands to the
    # command line interface.
    #
    # In order to create a command, add a class under
    # Bicho::CLI::Commands. Then you need to:
    # * Add options, using a Trollop syntax
    # * Implement do(global_opts, options, args)
    #
    # You can use t.say to talk to the terminal
    # including all HighLine features.
    #
    # <tt>
    # class Bicho::CLI::Commands::Hello < ::Bicho::CLI::Command
    #   options do
    #     opt :monkey, "Use monkey mode", :default => true
    #     opt :text, "Name", :type => :string
    #   end
    #
    #   def do(global_opts, opts, args)
    #     t.say("Hello")
    #   end
    # end
    # </tt>
    #
    class Command
      include ::Bicho::Logging

      class << self; attr_accessor :parser end

      attr_accessor :t

      def initialize
        @t = HighLine.new
      end

      # Gateway to Trollop
      def self.opt(*args)
        self.parser = Trollop::Parser.new unless parser
        parser.opt(*args)
      end

      # DSL method to describe a command's option
      def self.options
        yield
      end

      # Called by the cli to get the options
      # with current ARGV
      def parse_options
        self.class.parser = Trollop::Parser.new unless self.class.parser
        opts = Trollop.with_standard_exception_handling(self.class.parser) do
          o = self.class.parser.parse ARGV
        end
      end

      def parser
        self.class.parser
      end

      def do(_opts, _args)
        fail RuntimeError, "No implementation for #{self.class}" if self.class =~ /CommandTemplate/
      end
    end
  end
end
