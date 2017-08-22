#--
# Copyright (c) 2011 SUSE LINUX Products GmbH
# =>
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

module Bicho
  module Plugins
    # Novell bugzilla is behind ichain
    #
    # Plugin that rewrites the bugzilla API url
    # to the Novell internal endpoint without
    # ichain.
    #
    # Also, it takes your credentials from
    # your oscrc.
    #
    class Novell
      OSCRC_CREDENTIALS = 'https://api.opensuse.org'.freeze unless defined? OSCRC_CREDENTIALS
      DEFAULT_OSCRC_PATH = File.join(ENV['HOME'], '.oscrc') unless defined? DEFAULT_OSCRC_PATH
      DOMAINS = ['bugzilla.novell.com', 'bugzilla.suse.com']
      XMLRPC_DOMAINS = ['apibugzilla.novell.com', 'apibugzilla.suse.com']

      class << self
        attr_writer :oscrc_path
      end

      def self.oscrc_path
        @oscrc_path ||= DEFAULT_OSCRC_PATH
      end

      def to_s
        self.class.to_s
      end

      def self.oscrc_credentials
        oscrc = IniFile.load(oscrc_path)
        urls = [OSCRC_CREDENTIALS]
        urls << "#{OSCRC_CREDENTIALS}/" unless OSCRC_CREDENTIALS.end_with?('/')
        urls.each do |section|
          next unless oscrc.has_section?(section)
          user = oscrc[section]['user']
          pass = oscrc[section]['pass']
          return { user: user, password: pass } if user && pass
        end
        raise "No valid .oscrc credentials for Novell/SUSE bugzilla (#{oscrc_path})"
      end

      def transform_site_url_hook(url, _logger)
        case url.to_s
        when 'bnc', 'novell' then 'https://bugzilla.novell.com'
        when 'bsc', 'suse' then 'https://bugzilla.suse.com'
        when 'boo', 'opensuse' then 'https://bugzilla.opensuse.org'
        else url
        end
      end

      def transform_api_url_hook(url, logger)
        return url unless DOMAINS.map { |domain| url.host.include?(domain) }.any?

        begin
          url = url.clone
          url.host = url.host.gsub(/bugzilla\.novell.com/, 'apibugzilla.novell.com')
          url.host = url.host.gsub(/bugzilla\.suse.com/, 'apibugzilla.suse.com')
          url.scheme = 'https'

          logger.debug("#{self} : Rewrote url to '#{url}'")
        rescue StandardError => e
          logger.warn e
        end
        url
      end

      def transform_xmlrpc_client_hook(client, logger)
        return unless XMLRPC_DOMAINS.map { |domain| client.http.address.include?(domain) }.any?

        auth = Novell.oscrc_credentials
        client.user = auth[:user]
        client.password = auth[:password]
        logger.debug("#{self} : updated XMLRPC client with oscrc auth information")
      rescue StandardError => e
        logger.error e
      end
    end
  end
end
