# frozen_string_literal: true

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

require 'bicho/cli/command'
require 'bicho/client'
require 'bicho'
require 'bicho/query'
require 'pp'

module Bicho::CLI::Commands
  # Command to search for bugs.
  class Search < ::Bicho::CLI::Command
    options do
      # add all fields as command line options of this command
      Bicho::SEARCH_FIELDS.each do |field|
        opt field[0], field[2], type: field[1], multi: field[3]
      end
      opt :format, 'Output format (json, prometheus)', type: :string
    end

    def do(global_opts, opts, _args)
      server = ::Bicho::Client.new(global_opts[:bugzilla])
      Bicho.client = server
      # for most parameter we accept arrays, and also multi mode
      # this means parameters come in arrays of arrays
      query = ::Bicho::Query.new
      opts.each do |n, v|
        # skip any option that is not part of SEARCH_FIELDS
        next unless Bicho::SEARCH_FIELDS.map { |x| x[0] }.include?(n)
        next if v.nil? || v.flatten.empty?
        v.flatten.each do |single_val|
          query.send(n.to_sym, single_val)
        end
      end

      case opts[:format]
      when 'prometheus'
        STDOUT.puts Bicho::Export.to_prometheus_push_gateway(query)
      else
        server.search_bugs(query).each do |bug|
          t.say("#{t.color(bug.id.to_s, :headline)} #{bug.summary}")
        end
      end
      0
    end
  end
end
