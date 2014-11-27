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
require 'stringio'

module Bicho
  class Change
    def field_name
      @data['field_name']
    end

    def removed
      @data['removed']
    end

    def added
      @data['added']
    end

    def to_s
      buffer = StringIO.new
      buffer << "- #{field_name} = #{removed}\n"
      buffer << "+ #{field_name} = #{added}"
      buffer.string
    end

    def initialize(client, data)
      @client = client
      @data = data
    end
  end

  class ChangeSet
    # return [Date] The date the bug activity/change happened.
    def date
      @data['when'].to_date
    end

    # @return [String] The login name of the user who performed the bug change
    def who
      @data['who']
    end

    # @return [Array<Change>] list of changes, with details of what changed
    def changes
      @data['changes'].map do |change|
        Change.new(@client, change)
      end
    end

    def initialize(client, data)
      @client = client
      @data = data
    end

    def to_s
      buffer = StringIO.new
      buffer << "#{date}- #{who}\n"
      changes.each do |diff|
        buffer << "#{diff}\n"
      end
      buffer.string
    end
  end

  # A collection of Changesets associated with a bug
  class History
    include Enumerable

    # iterate over each changeset
    def each
      changesets.each
    end

    # @return [Fixnum] number of changesets
    def size
      changesets.size
    end

    # @return [Boolean] true when there are no changesets
    def empty?
      changesets.empty?
    end

    def initialize(client, data)
      @client = client
      @data = data
    end

    def bug_id
      @data['id']
    end

    # @return [String] The numeric id of the bug
    def bug
      unless @bug
        @bug = @client.get_bug(@data['id'])
      end
      @bug
    end

    # @return [Array<ChangeSet>] collection of changesets
    def changesets
      @data['history'].map do |changeset|
        ChangeSet.new(@client, changeset)
      end
    end

    def to_s
      buffer = StringIO.new
      buffer << "#{bug_id}\n"
      changesets.each do |cs|
        buffer << "#{cs}\n"
      end
      buffer.string
    end
  end
end
