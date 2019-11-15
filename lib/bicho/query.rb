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
require 'bicho/common_client'

module Bicho
  # Represents a bug search to the server and it can
  # be configured with all bug attributes.
  #
  #
  class Query
    include Enumerable

    # Iterates through the result of the current query.
    #
    # @note Requires Bicho.client to be set
    #
    # @yield [Bicho::Bug]
    def each
      ret = Bicho.client.search_bugs(self)
      return ret.each unless block_given?
      ret.each { |bug| yield bug }
    end

    # obtains the parameter that can be passed to the XMLRPC API
    # @private
    attr_reader :query_map

    # Create a query.
    #
    # @example query from a hash containing the attributes:
    #   q = Query.new({:summary => "substring", :assigned_to => "foo@bar.com"})
    #
    # @example using chainable methods:
    #   q = Query.new.assigned_to("foo@bar.com@).summary("some text")
    #
    def initialize(conditions = {})
      @query_map = conditions
    end

    # Query responds to all the bug search attributes.
    #
    # @see {Bug.where Allowed attributes}
    def method_missing(method_name, *args)
      return super unless Bicho::SEARCH_FIELDS
                          .map(&:first)
                          .include?(method_name)
      args.each do |arg|
        append_query(method_name.to_s, arg)
      end
      self
    end

    def respond_to_missing?(method_name, _include_private = false)
      Bicho::SEARCH_FIELDS.map(&:first).include?(method_name) || super
    end

    # Shortcut equivalent to status new, assigned, needinfo, reopened, confirmed, and in_progress
    def open
      status(:new).status(:assigned).status(:needinfo).status(:reopened).status(:confirmed).status(:in_progress)
    end

    # Shortcut, equivalent to
    #   :summary => "L3"
    def L3 # rubocop:disable Naming/MethodName
      append_query('summary', 'L3')
      self
    end

    private

    # Appends a parameter to the query map
    #
    # Only used internally.
    #
    # If the parameter already exists that parameter is converted to an
    # array of values
    #
    # @private
    def append_query(param, value)
      @query_map[param] = [] unless @query_map.key?(param)
      @query_map[param] = [@query_map[param], value].flatten
    end
  end
end
