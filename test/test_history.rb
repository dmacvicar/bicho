require_relative 'helper'

# Test for bug history
class HistoryTest < Minitest::Test
  def test_basic_history
    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')

    bug = Bicho.client.get_bug(645150)

    history = bug.history

    assert !history.empty?

    history.each do |c|
      assert c.timestamp.to_time.to_i > 0
    end
  end

  def teardown
    Bicho.client = nil
  end
end
