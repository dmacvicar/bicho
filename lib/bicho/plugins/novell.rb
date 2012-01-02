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

      def to_s
        self.class.to_s
      end

      def self.oscrc_credentials
        oscrc = IniFile.new(File.join(ENV['HOME'], '.oscrc'))
        if oscrc.has_section?(OSCRC_CREDENTIALS)
          user = oscrc[OSCRC_CREDENTIALS]['user']
          pass = oscrc[OSCRC_CREDENTIALS]['pass']
          if user && pass
            return {:user => user, :password => pass}
          else
            raise "No .oscrc credentials for bnc"
          end
        end
      end

      def transform_api_url_hook(url, logger)
        
        return url if not url.host.include?('bugzilla.novell.com')

        auth = Novell.oscrc_credentials
        
        url = url.clone
        url.user = auth[:user]
        url.password = auth[:password]
        url.host = url.host.gsub(/bugzilla\.novell.com/, 'apibugzilla.novell.com')
        url.path = url.path.gsub(/xmlrpc\.cgi/, 'tr_xmlrpc.cgi')

        logger.debug("#{self} : Rewrote url to '#{url.to_s.gsub(/#{url.user}:#{url.password}/, "USER:PASS")}'")
        return url
      end

    end
  end
end
