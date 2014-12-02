require 'bicho/cache'
require 'stringio'

module Bicho

  class Metrics
    # Initialize metrics with a cached storage
    def initialize(cache)
      @cache = cache
    end

    def write_monthly_stats_csv(buf)
      buf.puts %w(Month Open Closed New).join("\t")
      @cache.db.execute('SELECT * FROM months_stat') do |row|
        row[2] = row[2] * -1
        buf.puts row.join("\t")
      end
    end

  end
end
