require 'spec_helper'

RSpec.describe Sneakers::Metrics::InfluxDBMetrics do
  let(:params) { Hash.new(host: 'localhost') }
  let(:client) { double(::InfluxDB::Client) }
  subject(:instance) { described_class.new(params) }

  before do
    allow(::InfluxDB::Client).to receive(:new).with(params).and_return(client)
  end

  describe '#initialize' do
    it 'should receive params to initialize an InfluxDB::Client object' do
      expect(::InfluxDB::Client).to receive(:new).with(params)
      subject
    end
  end

  describe '#client' do
    subject { instance.client }

    it { is_expected.to be client }
  end

  describe '#increment' do
    let(:series) { 'sneakers_increment' }
    subject { instance.increment(param) }

    context 'when param is a String' do
      before do
        expect(client).to receive(:write_point).with(series, expected_write_params)
      end

      context 'when param is started type' do
        let(:param) { 'work.MyWorker.started' }
        let(:expected_write_params) do
          {
            values: { value: 1 },
            tags:   { worker: 'MyWorker', status: 'started' }
          }
        end

        it { subject }
      end

      context 'when param is ended type' do
        let(:param) { 'work.MyWorker.ended' }
        let(:expected_write_params) do
          {
            values: { value: 1 },
            tags:   { worker: 'MyWorker', status: 'ended' }
          }
        end

        it { subject }
      end

      context 'when param is handled type' do
        let(:param) { 'work.MyWorker.handled.ack' }
        let(:expected_write_params) do
          {
            values: { value: 1 },
            tags:   { worker: 'MyWorker', status: 'handled', type: 'ack' }
          }
        end

        it { subject }
      end
    end

    context 'when param is not a String' do
      let(:param) { :'not string type' }

      it { expect { subject }.to raise_error(RuntimeError) }
    end

    context 'when param cannot be matched' do
      let(:param) { 'imnotwork.MyWorker.not_a_status' }

      it { expect { subject }.to raise_error(RuntimeError) }
    end
  end

  describe '#timing' do
    let(:series) { 'sneakers_timing' }
    let(:param) { 'work.MyWorker.time' }

    subject { instance.timing(param, &block) }

    context 'when param is a String' do
      context 'when param is as expected' do
        let(:block) do
          x = double()
          expect(x).to receive(:should_be_called)
          proc { x.should_be_called }
        end
        let(:elapsed_time) { 0.5 }
        let(:expected_write_params) do
          {
            values: { value: elapsed_time },
            tags: {
              worker: 'MyWorker',
              status: 'timing'
            }
          }
        end

        before do
          allow(client).to receive(:write_point)
        end

        it 'should measure elapsed time using Benchmark.realtime' do
          expect(client).to receive(:write_point)
                              .with(series, hash_including(tags: {
                                                     worker: 'MyWorker',
                                                     status: 'timing'
                                                   }))
          expect(Benchmark).to receive(:realtime).and_call_original
          subject
        end
      end
    end

    context 'when param is not a String type' do
      let(:param) { :'not string type' }
      let(:block) { nil }

      it { expect { subject }.to raise_error(RuntimeError) }
    end

    context 'when its not executed with a block' do
      let(:block) { nil }

      it { expect { subject }.to raise_error(RuntimeError) }
    end
  end

  it 'has a version number' do
    expect(Sneakers::Metrics::InfluxDBMetrics::VERSION).not_to be nil
  end
end
