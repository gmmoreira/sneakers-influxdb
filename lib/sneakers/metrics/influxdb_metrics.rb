require 'sneakers/metrics/influxdb_metrics/version'
require 'influxdb'
require 'benchmark'

module Sneakers
  module Metrics
    class InfluxDBMetrics
      attr_reader :client

      def initialize(params)
        @client = ::InfluxDB::Client.new(params)
      end

      def increment(metric)
        raise RuntimeError, 'Metric must be a String type' unless metric.is_a?(String)

        tags = increment_tags(metric)

        client.write_point(
          values: { value: 1 },
          tags: increment_tags(metric)
        )
      end

      def timing(metric, &block)
        raise RuntimeError, 'Metric must be a String type' unless metric.is_a?(String)
        raise RuntimeError, 'Timing must receive a block parameter' unless block_given?

        elapsed = Benchmark.realtime(&block)

        client.write_point(
          values: { value: elapsed },
          tags: timing_tags(metric)
        )
      end

      private

      def increment_tags(metric)
        if /\A                   #match start of string
            work\.               #match work
            (?<worker>[^\.]+?)\. #match worker name
            (?<status>[^\.]+?)   #match worker status
            \z                   #match end of string
            /x =~ metric
          {
            worker: worker,
            status: status
          }
        elsif /\A                  #match start of string
               work\.              #match work
              (?<worker>[^\.]+?)\. #match worker name
              handled\.            #match message handled
              (?<type>[^\.]+?)     #match message handled type
              \z                   #match end of string
              /x =~ metric
          {
            worker: worker,
            status: 'handled',
            type: type
          }
        else
          raise RuntimeError, "Increment metric cannot be matched. Metric: #{metric}"
        end
      end

      def timing_tags(metric)
        if /\A                  #match start of string
           work\.               #match work
           (?<worker>[^\.]+?)\. #match worker name
           time                 #match time type
           /x =~ metric
          {
            worker: worker,
            status: 'timing'
          }
        else
          raise RuntimeError, "Timing metric cannot be matched. Metric: #{metric}"
        end
      end
    end
  end
end
