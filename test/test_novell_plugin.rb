require File.join(File.dirname(__FILE__), 'helper')
require 'bicho/plugins/novell'
require 'tmpdir'

class NovellPlugin_test < Test::Unit::TestCase

  def test_urls_are_correct
    client = Bicho::Client.new('https://bugzilla.novell.com')

    assert_raises NoMethodError do
      client.url
    end

    assert_equal 'https://apibugzilla.novell.com/xmlrpc.cgi', "#{client.api_url.scheme}://#{client.api_url.host}#{client.api_url.path}"
    assert_equal 'https://bugzilla.novell.com', "#{client.site_url.scheme}://#{client.site_url.host}#{client.site_url.path}"
  end

  def self.write_fake_oscrc(path)
    File.open(path, 'w') do |f|
      f.write(<<EOS)
[https://api.opensuse.org]
user = foo
pass = bar
# fake osc file
EOS
    end
  end

  def test_oscrc_parsing
    Dir.mktmpdir do |tmp|
      fake_oscrc = File.join(tmp, 'oscrc')
      NovellPlugin_test.write_fake_oscrc(fake_oscrc)
      Bicho::Plugins::Novell.oscrc_path = fake_oscrc
      plugin = Bicho::Plugins::Novell.new
      credentials = Bicho::Plugins::Novell.oscrc_credentials
      assert_not_nil(credentials)
      assert(credentials.has_key?(:user))
      assert(credentials.has_key?(:password))
      Bicho::Plugins::Novell.oscrc_path = nil
    end
  end

end
