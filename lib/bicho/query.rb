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

  class Query

    # Iterates through the result of the
    # current query.
    #
    # Requires Bicho.client to be set
    def each
      ret = Bicho.client.search(self)
      if block_given?
        ret.each { |bug| yield bug }
      end
      return Enumerable::Enumerator.new(ret)
    end

    # obtains the parameter that can be
    # passed to the XMLRPC API
    attr_reader :query_map

    # Create a query.
    # Optionally you can create a
    # query from a hash containing
    # the attributes:
    #
    # m = {:summary => "substring", :assigned_to => "foo@bar.com"}
    # q = Query.new(m)
    #
    # Or you can use the chainable methods:
    # q = Query.new.assigned_to("foo@bar.com@).summary("some text")
    #
    def initialize(query_map={})
      @query_map = Hash.new
    end

    def method_missing(name, *args)
      args.each do |arg|
        append_query(name.to_s, arg)
      end
      self
    end

    def L3
      append_query("summary", "L3")
      self
    end

    private
    # Appends a query parameter.
    # If the parameter already exists
    # that parameter is converted to an
    # array of values
    #
    # only used internally
    def append_query(param, value)
      if not @query_map.has_key?(param)
        @query_map[param] = Array.new
      end
      @query_map[param] = value
    end

  end

end
