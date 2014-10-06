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

      OSCRC_CREDENTIALS = "https://api.opensuse.org"
      DEFAULT_OSCRC_PATH = File.join(ENV['HOME'], '.oscrc')

      def self.oscrc_path=(path)
        @oscrc_path = path
      end

      def self.oscrc_path
        @oscrc_path ||= DEFAULT_OSCRC_PATH
      end

      def to_s
        self.class.to_s        
      end

      def self.oscrc_credentials        
        oscrc = IniFile.new(oscrc_path)
        urls = [OSCRC_CREDENTIALS]
        urls << "#{OSCRC_CREDENTIALS}/" if not OSCRC_CREDENTIALS.end_with?('/')
        urls.each do |section|
          if oscrc.has_section?(section)
            user = oscrc[section]['user']
            pass = oscrc[section]['pass']
            if user && pass
              return {:user => user, :password => pass}
            end
          end
        end
        raise "No valid .oscrc credentials for bnc. #{user} #{pass}"
      end

      def transform_api_url_hook(url, logger)
        
        return url if not url.host.include?('bugzilla.novell.com')

        auth = Novell.oscrc_credentials
        
        url = url.clone
        url.user = auth[:user]
        url.password = auth[:password]
        url.host = url.host.gsub(/bugzilla\.novell.com/, 'apibugzilla.novell.com')

        logger.debug("#{self} : Rewrote url to '#{url.to_s.gsub(/#{url.user}:#{url.password}/, "USER:PASS")}'")
        return url
      end

    end
  end
end
