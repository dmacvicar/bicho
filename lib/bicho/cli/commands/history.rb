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
require 'pp'

module Bicho::CLI::Commands
  # command that shows the history colored as a
  # changelog
  class History < ::Bicho::CLI::Command

    def do(global_opts, _opts, args)
      client = ::Bicho::Client.new(global_opts[:bugzilla])
      client.get_history(*args).each do |history|
        t.say("#{t.color(history.bug_id.to_s, :headline)} #{history.bug.summary}")
        history.change_sets.each do |cs|
          text = "  #{cs.date} - #{cs.who}"
          t.say(t.color(text, :changeset))
          cs.changes.each do |change|
            text = "    - #{change.field_name} = #{change.removed}"
            t.say(t.color(text, :remove))
            text = "    + #{change.field_name} = #{change.added}"
            t.say(t.color(text, :add))
          end
        end
      end
      0
    end
  end
end
