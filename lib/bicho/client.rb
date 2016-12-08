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
require 'nokogiri'
require 'net/https'
require 'cgi'

require 'bicho/attachment'
require 'bicho/bug'
require 'bicho/history'
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
    @http.set_debug_output(Bicho::LoggerIODevice.new)
  end
end

module Bicho
  # Plugins are defined inside this module
  module Plugins
  end

  # Client to query bugzilla
  class Client
    include Bicho::Logging

    # @return [URI] XML-RPC API end-point
    #
    # This URL is automatically inferred from the
    # Client#site_url
    #
    # Plugins can modify the inferred value by providing
    # a transform_api_url_hook(url, logger) method returning
    # the modified value.
    #
    attr_reader :api_url

    # @return [URI] Bugzilla installation website
    #
    # This value is provided at construction time
    attr_reader :site_url

    # @return [String] user id, available after login
    attr_reader :userid

    # @visibility private
    # Implemented only to warn users about the replacement
    # APIs
    def url
      warn 'url is deprecated. Use site_url or api_url'
      raise NoMethodError
    end

    # @param [String] site_url Bugzilla installation site url
    # @param [String] username Bugzilla account username
    # @param [String] password Bugzilla account password
    def initialize(site_url, username=nil, password=nil)
      @plugins = []
      load_plugins!
      instantiate_plugins!

      if site_url.nil?
        @plugins.each do |pl_instance|
          if pl_instance.respond_to?(:default_site_url_hook)
            default = pl_instance.default_site_url_hook(logger)
            site_url = default unless default.nil?
          end
        end
      end

      # If the default url is still null, we can't continue
      raise ArgumentError, 'missing bugzilla site' if site_url.nil?

      @plugins.each do |pl_instance|
        if pl_instance.respond_to?(:transform_site_url_hook)
          site_url = pl_instance.transform_site_url_hook(site_url, logger)
        end
      end

      # Don't modify the original url
      @site_url = site_url.is_a?(URI) ? site_url.clone : URI.parse(site_url)

      api_url = @site_url.clone
      api_url.path = '/xmlrpc.cgi'

      @plugins.each do |pl_instance|
        # Modify API url
        if pl_instance.respond_to?(:transform_api_url_hoot)
          api_url = pl_instance.transform_api_url_hook(api_url, logger)
        end
      end

      @api_url = api_url.is_a?(URI) ? api_url.clone : URI.parse(api_url)
      username ||= ENV['bz_username']
      password ||= ENV['bz_password']

      @client = XMLRPC::Client.new_from_hash(host: @api_url.hostname,
                                             port: 443,
                                             use_ssl: true,
                                             user: username,
                                             password: password,
                                             path: '/xmlrpc.cgi',
                                             proxy_host: nil,
                                             timeout: 900)
      @client.set_debug

      # User.login sets the credentials cookie for subsequent calls
      if @client.user && @client.password
        ret = @client.call('User.login', 'login' => @client.user, 'password' => @client.password, 'remember' => 0)
        handle_faults(ret)
        @userid = ret['id']
      end
    end

    # ruby-load all the files in the plugins directory
    def load_plugins!
      # Scan plugins
      plugin_glob = File.join(File.dirname(__FILE__), 'plugins', '*.rb')
      Dir.glob(plugin_glob).each do |plugin|
        logger.debug("Loading file: #{plugin}")
        require plugin
      end
    end

    # instantiate all plugin classes in the Bicho::Plugins
    # module and add them to the list of known plugins
    def instantiate_plugins!
      ::Bicho::Plugins.constants.each do |cnt|
        pl_class = ::Bicho::Plugins.const_get(cnt)
        pl_instance = pl_class.new
        logger.debug("Loaded: #{pl_instance}")
        @plugins << pl_instance
      end
    end

    def cookie
      @client.cookie
    end

    def handle_faults(ret)
      if ret.key?('faults')
        ret['faults'].each do |fault|
          logger.error fault
        end
      end
    end

    # Return Bugzilla API version
    def version
      ret = @client.call('Bugzilla.version')
      handle_faults(ret)
      ret['version']
    end

    # Create a bug
    #
    # @param product - the name of the product the bug is being filed against
    # @param component - the name of a component in the product above.
    # @param summary - a brief description of the bug being filed.
    # @param version - version of the product above; the version the bug was found in.
    # @param **kwargs - keyword-args containing optional/defaulted params
    #
    # Return the new bug ID
    def create_bug(product, component, summary, version, **kwargs)
      params = {}
      params = params.merge(kwargs)
      params[:product] = product
      params[:component] = component
      params[:summary] = summary
      params[:version] = version
      ret = @client.call('Bug.create', params)
      handle_faults(ret)
      ret['id']
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

      ret = @client.call('Bug.search', query.query_map)
      handle_faults(ret)
      bugs = []
      ret['bugs'].each do |bug_data|
        bugs << Bug.new(self, bug_data)
      end
      bugs
    end

    # Given a named query's name, runs it
    # on the server
    # @returns [Array<String>] list of bugs
    def expand_named_query(what)
      url = @api_url.clone
      url.path = '/buglist.cgi'
      url.query = "cmdtype=runnamed&namedcmd=#{URI.escape(what)}&ctype=atom"
      logger.info("Expanding named query: '#{what}' to #{url.request_uri}")
      fetch_named_query_url(url, 5)
    end

    # Fetches a named query by its full url
    # @private
    # @returns [Array<String>] list of bugs
    def fetch_named_query_url(url, redirects_left)
      raise 'You need to be authenticated to use named queries' unless @userid
      http = Net::HTTP.new(@api_url.host, @api_url.port)
      http.set_debug_output(Bicho::LoggerIODevice.new)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = (@api_url.scheme == 'https')
      # request = Net::HTTP::Get.new(url.request_uri, {'Cookie' => self.cookie})
      request = Net::HTTP::Get.new(url.request_uri)
      request.basic_auth @api_url.user, @api_url.password
      response = http.request(request)
      case response
      when Net::HTTPSuccess
        bugs = []
        begin
          xml = Nokogiri::XML.parse(response.body)
          xml.root.xpath('//xmlns:entry/xmlns:link/@href', xml.root.namespace).each do |attr|
            uri = URI.parse attr.value
            bugs << uri.query.split('=')[1]
          end
          return bugs
        rescue Nokogiri::XML::XPath::SyntaxError
          raise "Named query '#{url.request_uri}' not found"
        end
      when Net::HTTPRedirection
        location = response['location']
        if redirects_left.zero?
          raise "Maximum redirects exceeded (redirected to #{location})"
        end
        new_location_uri = URI.parse(location)
        logger.debug("Moved to #{new_location_uri}")
        fetch_named_query_url(new_location_uri, redirects_left - 1)
      else
        raise "Error when expanding named query '#{url.request_uri}': #{response}"
      end
    end

    # Gets a single bug
    # @return [Bug] a single bug by id
    def get_bug(id)
      get_bugs(id).first
    end

    # Retrieves one or more bugs by id
    # @return [Array<Bug>] a list of bugs
    def get_bugs(*ids)
      params = {}
      params[:ids] = ids.collect(&:to_s).map do |what|
        if what =~ /^[0-9]+$/
          next what.to_i
        else
          next expand_named_query(what)
        end
      end.flatten

      bugs = []
      ret = @client.call('Bug.get', params)
      handle_faults(ret)
      ret['bugs'].each do |bug_data|
        bugs << Bug.new(self, bug_data)
      end
      bugs
    end

    # @return [Array<History>] the history of the given bugs
    def get_history(*ids)
      params = {}
      params[:ids] = ids.collect(&:to_s).map do |what|
        if what =~ /^[0-9]+$/
          next what.to_i
        else
          next expand_named_query(what)
        end
      end.flatten

      histories = []
      ret = @client.call('Bug.history', params)
      handle_faults(ret)
      ret['bugs'].each do |history_data|
        histories << History.new(self, history_data)
      end
      histories
    end

    # @return [Array<Attachment>] a list of attachments for the
    # given bugs.
    #
    # Payload is lazy-loaded
    def get_attachments(*ids)
      params = {}
      params[:ids] = ids.collect(&:to_s).map do |what|
        if what =~ /^[0-9]+$/
          next what.to_i
        else
          next expand_named_query(what)
        end
      end.flatten

      ret = @client.call('Bug.attachments',
                         params.merge(exclude_fields: ['data']))
      handle_faults(ret)
      ret['bugs'].map do |_, attachments_data|
        attachments_data.map do |attachment_data|
          Attachment.new(self, @client, attachment_data)
        end
      end.flatten
    end

    # Add an attachment to bugs with given ids
    #
    # Params:
    # @param summary - a short string describing the attachment
    # @param file - [File] object to attach
    # @param *ids - a list of bug ids to which the attachment will be added
    # @param **kwargs - optional keyword-args that may contain:
    #  - content_type - content type of the attachment (if ommited,
    #  'application/octet-stream' will be used)
    #  - file_name - name of the file (if ommited, the base name of the
    #  provided file will be used)
    #  - patch? - flag saying that the attachment is a patch
    #  - private? - flag saying that the attachment is private
    #  - comment
    #
    # @return [Array<ID>] a list of the attachment id(s) created.
    def add_attachment(summary, file, *ids, **kwargs)
      params = {}
      params[:ids] = ids
      params[:summary] = summary
      params[:content_type] = kwargs.fetch(:content_type, 'application/octet-stream')
      params[:file_name] = kwargs.fetch(:file_name, File.basename(file))
      params[:is_patch] = kwargs[:patch?] if kwargs[:patch?]
      params[:is_private] = kwargs[:private?] if kwargs[:private?]
      params[:comment] = kwargs[:comment] if kwargs[:comment]
      params[:data] = XMLRPC::Base64.new(file.read)
      ret = @client.call('Bug.add_attachment', params)
      handle_faults(ret)
      ret['ids']
    end
  end
end
