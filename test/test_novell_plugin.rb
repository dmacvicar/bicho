require_relative 'helper'
require 'bicho/plugins/novell'
require 'logger'

# Test for the plugin supporting the Novell/SUSE bugzilla authentication
class NovellPluginTest < Minitest::Test
  def test_url_replacement
    r, w = IO.pipe
    log = Logger.new(w)
    %w(novell suse).each do |domain|
      creds = { user: 'test', password: 'test' }
      Bicho::Plugins::Novell.stub :oscrc_credentials, creds do
        plugin = Bicho::Plugins::Novell.new
        url = URI.parse("http://bugzilla.#{domain}.com")
        site_url = plugin.transform_site_url_hook(url, log)
        api_url = plugin.transform_api_url_hook(url, log)
        assert_equal(site_url.to_s, "http://bugzilla.#{domain}.com")
        assert_equal(api_url.to_s, "https://test:test@apibugzilla.#{domain}.com")
        assert_match(/Rewrote url/, r.gets)
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
