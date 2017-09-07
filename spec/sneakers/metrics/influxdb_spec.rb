require "spec_helper"

RSpec.describe Sneakers::Metrics::Influxdb do
  it "has a version number" do
    expect(Sneakers::Metrics::Influxdb::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
