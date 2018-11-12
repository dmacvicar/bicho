require 'json'
require 'stringio'

module Bicho
  # Utility methods for exporting bugs to other systems
  module Export
    # Exports full data of a bug to json, including some extended
    # calculated attributes.
    def self.to_json(bug)
      bug_h = bug.to_h
      bug_h['history'] = bug.history.changesets.map(&:to_h)
      bug_h['resolution_time'] = Bicho::Reports.resolution_time(bug)
      JSON.generate(bug_h)
    end

    # Export a query for usage as a metric in prometheus
    # See https://github.com/prometheus/pushgateway
    #
    # The metric name will be 'bugs_total'
    # See https://prometheus.io/docs/practices/naming/)
    #
    # And every attributed
    # specified in the query will be used as a label
    def self.to_prometheus_push_gateway(query)
      buf = StringIO.new
      dimensions = [:product, :status, :priority, :severity, :resolution, :component]
      grouped = query.to_a.group_by do |i|
        puts i
        dimensions.map { |d| [d, i[d]] }.to_h
      end

      buf.write("# TYPE bugs_total gauge\n")
      grouped.each do |attrs, set|
        labels = attrs
                 .map { |e| "#{e[0]}=\"#{e[1]}\"" }
                 .join(',')
        buf.write("bugs_total{#{labels}} #{set.size}\n")
      end
      buf.write("\n")
      buf.close
      buf.string
    end
  end
end
