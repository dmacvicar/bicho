require_relative 'helper'
require 'bicho/plugins/novell'
require 'logger'
require 'fakefs'

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
        assert_equal(api_url.to_s, 'https://test:test@apibugzilla.novell.com')
        assert_match(/Rewrote url/, r.gets)
      end
    end
  end

  def test_oscrc_parsing
    FakeFS do
      oscrc = <<EOS
[https://api.opensuse.org]
user = foo
pass = bar
# fake osc file
EOS
      FileUtils.mkdir_p File.join(ENV['HOME'])
      File.open(File.join(ENV['HOME'], '.oscrc'), 'w') do |f|
        f.write oscrc
      end
      credentials = Bicho::Plugins::Novell.oscrc_credentials
      refute_nil(credentials)
      assert(credentials.key?(:user))
      assert(credentials.key?(:password))
    end
  end
end
