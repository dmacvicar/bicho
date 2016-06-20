require File.join(File.dirname(__FILE__), 'helper')

# Test for bug history
class HistoryTest < Minitest::Test

  def test_basic_history
    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

    bug = Bicho.client.get_bug(645150)

    assert !bug.history.empty?
  end

  def teardown
    Bicho.client = nil
  end
end
