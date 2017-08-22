require_relative 'helper'
require 'bicho/plugins/novell'
require 'logger'

# Test for the plugin supporting the Novell/SUSE bugzilla authentication
class NovellPluginTest < Minitest::Test
  def test_url_replacement
    creds = { user: 'test', password: 'test' }
    %w(novell suse).each do |domain|
      r, w = IO.pipe
      log = Logger.new(w)
      Bicho::Plugins::Novell.stub :oscrc_credentials, creds do
        plugin = Bicho::Plugins::Novell.new
        url = URI.parse("http://bugzilla.#{domain}.com")
        site_url = plugin.transform_site_url_hook(url, log)
        api_url = plugin.transform_api_url_hook(url, log)
        assert_equal(site_url.to_s, "http://bugzilla.#{domain}.com")
        assert_equal(api_url.to_s, "https://apibugzilla.#{domain}.com")
        assert_match(/Rewrote url/, r.gets)
      end
    end
  end

  def test_xmlrpcclient_replacement
    creds = { user: 'test', password: 'test' }
    %w(novell suse).each do |domain|
      Bicho::Plugins::Novell.stub :oscrc_credentials, creds do
        r, w = IO.pipe
        log = Logger.new(w)

        plugin = Bicho::Plugins::Novell.new
        url = URI.parse("http://bugzilla.#{domain}.com")
        api_url = plugin.transform_api_url_hook(url, log)
        client = XMLRPC::Client.new_from_uri(api_url.to_s, nil, 900)
        plugin.transform_xmlrpc_client_hook(client, log)
        w.close
        assert_equal('test', client.user, 'xmlrpc client username should be set')
        assert_equal('test', client.password, 'xmlrpc client password should be set')
        assert_match(/updated XMLRPC client with oscrc auth information/, r.read)
      end
    end
  end

  def test_oscrc_parsing
    oscrc = <<EOS
[https://api.opensuse.org]
user = foo
pass = bar
# fake osc file
EOS

    Dir.mktmpdir do |tmp|
      fake_oscrc = File.join(tmp, '.oscrc')
      File.write(fake_oscrc, oscrc)
      Bicho::Plugins::Novell.stub :oscrc_path, fake_oscrc do
        credentials = Bicho::Plugins::Novell.oscrc_credentials
        refute_nil(credentials)
        assert(credentials.key?(:user))
        assert(credentials.key?(:password))
      end
    end
  end
end
