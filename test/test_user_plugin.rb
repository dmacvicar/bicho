require_relative 'helper'
require 'bicho/plugins/user'
require 'tmpdir'

# Test for the plugin implementing user
# preferences
class UserPluginTest < Minitest::Test

  def self.write_fake_config(path)
    File.open(path, 'w') do |f|
      f.write(<<EOS)
default: foobar
aliases:
  shazam: http://bugzilla.foobar.com
EOS
    end
  end

  def test_aliases_and_defaults
    Dir.mktmpdir do |tmp|
      fake_config = File.join(tmp, 'config.yml')
      UserPluginTest.write_fake_config(fake_config)
      Bicho::Plugins::User.config_path = fake_config
      plugin = Bicho::Plugins::User.new

      logger = Logger.new($stdout)

      assert_equal 'foobar', plugin.default_site_url_hook(logger)

      assert_equal 'unknown', plugin.transform_site_url_hook('unknown', logger)
      assert_equal 'http://bugzilla.foobar.com', plugin.transform_site_url_hook('shazam', logger)

      Bicho::Plugins::User.config_path = nil
    end
  end
end
