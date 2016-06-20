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

      #class << self
      #  attr_writer :oscrc_path
      #end

      def self.oscrc_path
        @oscrc_path ||= DEFAULT_OSCRC_PATH
      end

      def self.oscrc_path=(path)
        @oscrc_path = path
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
          if user && pass
            return { user: user, password: pass }
          end
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
        domains = ['bugzilla.novell.com', 'bugzilla.suse.com']
        return url unless domains.map { |domain| url.host.include?(domain) }.any?

        begin
          auth = Novell.oscrc_credentials

          url = url.clone
          url.user = auth[:user]
          url.password = auth[:password]
          url.host = url.host.gsub(/bugzilla\.novell.com/, 'apibugzilla.novell.com')
          url.host = url.host.gsub(/bugzilla\.suse.com/, 'apibugzilla.novell.com')
          url.scheme = 'https'

          logger.debug("#{self} : Rewrote url to '#{url.to_s.gsub(/#{url.user}:#{url.password}/, 'USER:PASS')}'")
        rescue StandardError => e
          logger.warn e
        end
        url
      end
    end
  end
end
