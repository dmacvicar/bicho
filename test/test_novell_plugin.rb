require File.join(File.dirname(__FILE__), 'helper')
require 'bicho/plugins/novell'

class NovellPlugin_test < Test::Unit::TestCase

  def test_urls_are_correct
    client = Bicho::Client.new('https://bugzilla.novell.com')

    assert_raises NoMethodError do
      client.url
    end

    assert_equal 'https://apibugzilla.novell.com/tr_xmlrpc.cgi', "#{client.api_url.scheme}://#{client.api_url.host}#{client.api_url.path}"
    assert_equal 'https://bugzilla.novell.com', "#{client.site_url.scheme}://#{client.site_url.host}#{client.site_url.path}"

  end

  def test_oscrc_parsing
    Bicho::Plugins::Novell.oscrc_path = "/space/tmp/oscrc-uwe"
    plugin = Bicho::Plugins::Novell.new
    credentials = Bicho::Plugins::Novell.oscrc_credentials
    assert_not_nil(credentials)
    assert(credentials.has_key?(:user))
    assert(credentials.has_key?(:password))
  end

end
