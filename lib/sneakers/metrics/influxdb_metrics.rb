require 'sneakers/metrics/influxdb_metrics/version'
require 'influxdb'

module Sneakers
  module Metrics
    class InfluxDBMetrics
      attr_reader :client

      def initialize(params)
        @client = ::InfluxDB::Client.new(params)
      end

      def increment(metric)
        raise RuntimeError, 'metric must be a String type' unless metric.is_a?(String)

        tags = increment_tags(metric)

        client.write_point(
          values: { value: 1 },
          tags: increment_tags(metric)
        )
      end

      private

      def increment_tags(metric)
        if /\Awork\.(?<worker>[^\.]+?)\.(?<status>[^\.]+?)\z/ =~ metric
          {
            worker: worker,
            status: status
          }
        elsif /\Awork\.(?<worker>[^\.]+?)\.handled\.(?<type>[^\.]+?)\z/ =~ metric
          {
            worker: worker,
            status: 'handled',
              type: type
          }
        else
          raise RuntimeError, "Increment metrica cannot be matched. Metric: #{metric}"
        end
      end
    end
  end
end
