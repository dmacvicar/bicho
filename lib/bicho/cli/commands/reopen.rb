#--
# Copyright (c) 2011 SUSE LINUX Products GmbH
#
# Author: Klaus Kämpf <kkaempf@suse.de>
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

module Bicho
  module CLI
    module Commands
      # Command to reopen a bug.
      class Reopen < ::Bicho::CLI::Command
        options do
          opt :comment, 'Comment to add', type: :string
          opt :private, 'Set the comment to private', type: :boolean
        end

        def do(global_opts, opts, args)
          unless opts[:comment]
            t.say('Reopen must have a comment')
            return 1
          end
          client = ::Bicho::Client.new(global_opts[:bugzilla])
          client.get_bugs(*args).each do |bug|
            id = bug.reopen!(opts[:comment], opts[:private])
            if id == bug.id
              t.say("Bug #{id} reopened")
            else
              t.say("#{t.color('ERROR:', :error)} Failed to reopen bug #{id}")
            end
          end
          0
        end
      end
    end
  end
end
