require_relative 'helper'
require 'bicho/metrics'
require 'pp'

class MetricsTest < Test::Unit::TestCase

  def test_metrics
    Bicho.client = Bicho::Client.new('https://bugzilla.suse.com')
    bugs = Bicho::Bug.where
           .product('SUSE Manager Server 1.2')
           .product('SUSE Manager Proxy 1.2')
           .product('SUSE Manager 1.7 Server')
           .product('SUSE Manager 1.7 Proxy')
           .product('SUSE Manager 2.1 Server')
           .product('SUSE Manager 2.1 Proxy')

    bugids = bugs.map(&:id)
    histories = Bicho.client.get_history(*bugids)

    cache = Bicho::Cache.new
    bugs.each do |bug|
      cache.add_bug_basic(bug)
    end

    histories.each do |history|
      cache.add_bug_history(history)
    end

    metrics = Bicho::Metrics.new(cache)
  end

end
