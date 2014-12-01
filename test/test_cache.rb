require_relative 'helper'
require 'bicho/cache'

class CacheTest < Test::Unit::TestCase

  def test_cache

    Bicho.client = Bicho::Client.new('https://bugzilla.redhat.com')
    bugs = Bicho.client.get_bugs(848894, 946924, 992667)

    histories = Bicho.client.get_history(848894, 946924, 992667)

    cache = Bicho::Cache.new
    bugs.each do |bug|
      cache.add_bug_basic(bug)
    end

    histories.each do |history|
      cache.add_bug_history(history)
    end

  end

end
