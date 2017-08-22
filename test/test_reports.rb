require_relative 'helper'

# Test reports on bugs
class ReportsTest < Minitest::Test
  def test_resolution_date
    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')
    bug = Bicho.client.get_bug(777777)
    ts = Bicho::Reports.resolution_time(bug)
    assert_equal(Time.parse('2017-01-26 09:06:09 UTC'), ts)
  end

  def test_ranges_with_statuses
    Bicho.client = Bicho::Client.new('https://bugzilla.gnome.org')
    bug = Bicho.client.get_bug(312619)
    ranges = Bicho::Reports.ranges_with_statuses(bug, 'NEEDINFO')
    assert_equal(
      [Time.parse('2005-12-31 21:56:36 UTC')..Time.parse('2006-04-11 19:22:41 UTC')], ranges
    )

    ranges = Bicho::Reports.ranges_with_statuses(bug, 'NEEDINFO', 'RESOLVED')
    assert_equal(Time.parse('2005-12-31 21:56:36 UTC')..Time.parse('2006-04-11 19:22:41 UTC'), ranges[0])
    assert_equal(Time.parse('2006-04-11 19:22:41 UTC'), ranges[1].begin)
    assert(Time.now - ranges[1].end < 60)
  end
end
