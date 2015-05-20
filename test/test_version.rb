require File.join(File.dirname(__FILE__), 'helper')

#
# Test getting the version of the Bugzilla API
#
class Version_test < Test::Unit::TestCase
  def test_version_gnome
    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

    ret  = Bicho::client.version
    assert ret =~ /3.4/ # https://bugzilla.gnome.org/ is at 3.4.13 as of Jan/2015
  end

  def test_version_suse
    Bicho.client = Bicho::Client.new('https://bugzilla.suse.com')

    ret  = Bicho::client.version
    assert ret =~ /4.4/ #https://bugzilla.suse.com is at 4.4.6 as of Jan/2015
  end

end
