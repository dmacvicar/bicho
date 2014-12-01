require 'bicho/cache'

module Bicho

  class Metrics
    # Initialize metrics with a cached storage
    def initialize(cache)
      @cache = cache
    end

    def monthly_metrics_for_range(from, to)
      metrics_for_dates(
        (from..to).select {|d| d.day == 1}.to_enum(:each))
    end

    
    def metrics_for_dates(dates)
      dates.each do |date|
        puts date
      end
    end
  end
end
