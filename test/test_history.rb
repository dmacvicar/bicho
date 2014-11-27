require File.join(File.dirname(__FILE__), 'helper')

class History_test < Test::Unit::TestCase

  def test_basic_history
    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

    bug = Bicho.client.get_bug(645150)

    assert bug.history.size > 0
  end

end
