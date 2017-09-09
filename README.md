# Sneakers::Metrics::InfluxDB

This gem collect metrics from Sneakers workers and insert them in InfluxDB. Those metrics can be useful so you know how many works you are doing, how many started and ended, as well the time each work takes to execute.

This gem depends on `influxdb` gem 0.3.x. This branch supports Ruby 2.1 and less, so it shouldn't break current compatibility while using Sneakers and Bunny gems.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sneakers-metrics-influxdb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sneakers-metrics-influxdb

## Usage

Where you configure the Sneakers gem, pass the object Sneakers::Metrics::InfluxDBMetrics to the metrics option.

Example:

```ruby
influxdb_metrics = Sneakers::Metrics::InfluxDBMetrics.new('sneakers', host: 'localhost',
                                                                      port: 8086,
                                                                      username: 'admin',
                                                                      password: 'admin')

Sneakers.configure(workers:           8,
                   threads:           1,
                   timeout_job_after: 2,
                   log: Rails.logger,
                   metrics: influxdb_metrics)
```

The InfluxDBMetrics initializer receives the same params as the InfluxDB::Client class. You can also pass an instance of InfluxDB::Client if you already uses the client in other parts of your project.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gmmoreira/sneakers-metrics-influxdb.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
