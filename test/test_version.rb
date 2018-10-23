require_relative 'helper'

# Test getting the version of the Bugzilla API
class VersionTest < Minitest::Test
  def test_version_gnome
    VCR.use_cassette('bugzilla.gnome.org_version') do
      Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

      ret = Bicho.client.version
      # https://bugzilla.gnome.org/ is at 4.4.12 as of Jun/2016
      assert_match(/4.4/, ret)
    end
  end

  def test_version_suse
    VCR.use_cassette('bugzilla.opensuse.org_version') do
      Bicho.client = Bicho::Client.new('https://bugzilla.opensuse.org')

      ret = Bicho.client.version
      # https://bugzilla.suse.com is at 4.4.6 as of Jan/2015
      assert_match(/4.4/, ret)
    end
  end
end
