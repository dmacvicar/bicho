require File.join(File.dirname(__FILE__), 'helper')
require 'bicho/plugins/novell'
require 'tmpdir'

# Test for the plugin supporting the
# Novell/SUSE bugzilla authentication
class NovellPluginTest < Minitest::Test
  def test_urls_are_correct
    %w(novell suse).each do |domain|
      client = Bicho::Client.new("https://bugzilla.#{domain}.com")
      assert_raises NoMethodError do
        client.url
      end
    end
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
      NovellPluginTest.write_fake_oscrc(fake_oscrc)
      Bicho::Plugins::Novell.oscrc_path = fake_oscrc
      plugin = Bicho::Plugins::Novell.new
      credentials = Bicho::Plugins::Novell.oscrc_credentials
      assert_not_nil(credentials)
      assert(credentials.key?(:user))
      assert(credentials.key?(:password))
      Bicho::Plugins::Novell.oscrc_path = nil
    end
  end
end
