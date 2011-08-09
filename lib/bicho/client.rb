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
require 'inifile'
require 'uri'
require 'xmlrpc/client'

require 'bicho/bug'
require 'bicho/query'
require 'bicho/logging'

# Helper IO device that forwards to the logger, we use it
# to debug XMLRPC by monkey patching it
#
# @private
class Bicho::LoggerIODevice
  def <<(msg)
    Bicho::Logging.logger.debug(msg)
  end
end

# monkey patch XMLRPC
#
# @private
class XMLRPC::Client
  def set_debug
    @http.set_debug_output(Bicho::LoggerIODevice.new);
  end
end

module Bicho

  module Plugins
  end

  # Client to query bugzilla
  class Client

    include Bicho::Logging

    attr_reader :url

    def initialize(url)
      url = URI.parse(url) if not url.is_a?(URI)
      # save the unmodified (by plugins) url
      @url = url.clone

      url.path = '/xmlrpc.cgi'

      # Scan plugins
      plugin_glob = File.join(File.dirname(__FILE__), 'plugins', '*.rb')
      Dir.glob(plugin_glob).each do |plugin|
        logger.debug("Loading file: #{plugin}")
        load plugin
      end

      #instantiate plugins
      ::Bicho::Plugins.constants.each do |cnt|
        pl_class = ::Bicho::Plugins.const_get(cnt)
        pl_instance = pl_class.new
        logger.debug("Loaded: #{pl_instance}")
        pl_instance.initialize_hook(url, logger)
      end

      @client = XMLRPC::Client.new_from_uri(url.to_s, nil, 900)
      @client.set_debug
    end

    def handle_faults(ret)
      if ret.has_key?('faults')
        ret['faults'].each do |fault|
          logger.error fault
        end
      end
    end

    # Search for a bug
    #
    # +query+ has to be either a +Query+ object or
    # a +String+ that will be searched in the summary
    # of the bugs.
    #
    def search_bugs(query)
      # allow plain strings to be passed, interpretting them
      query = Query.new.summary(query) if query.is_a?(String)

      ret = @client.call("Bug.search", query.query_map)
      handle_faults(ret)
      bugs = []
      ret['bugs'].each do |bug_data|
        bugs << Bug.new(self, bug_data)
      end
      bugs
    end

    # Retrieves one or more bugs by id
    def get_bugs(*ids)
      params = Hash.new
      params[:ids] = ids.collect(&:to_s)

      bugs = []
      ret = @client.call("Bug.get", params)
      handle_faults(ret)
      ret['bugs'].each do |bug_data|
        bugs << Bug.new(self, bug_data)
      end
      bugs
    end

  end
end
