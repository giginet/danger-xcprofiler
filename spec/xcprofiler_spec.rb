require File.expand_path('../spec_helper', __FILE__)
require 'xcprofiler'

module Danger
  describe Danger::DangerXcprofiler do
    it 'should be a plugin' do
      expect(Danger::DangerXcprofiler.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      let(:product_name) { 'MyApp' }
      let(:derived_data) { double('derived_data') }
      let(:profiler) { Xcprofiler::Profiler.new(derived_data) }
      let(:location) { 'path/to/Source.swift:20:30' }
      let(:method_name) { 'doSomething()' }
      let(:time0) { 99.9 }
      let(:time1) { 100 }
      let(:execution0) { Xcprofiler::Execution.new(time0, location, method_name) }
      let(:execution1) { Xcprofiler::Execution.new(time1, location, method_name) }

      before do
        @dangerfile = testing_dangerfile
        @xcprofiler = @dangerfile.xcprofiler
        @xcprofiler.working_dir = ''
        allow(@dangerfile).to receive(:warn)
        allow(@dangerfile).to receive(:fail)
        allow(Xcprofiler::Profiler).to receive(:by_product_name).with(product_name).and_return(profiler)
        allow(derived_data).to receive(:flag_enabled?).and_return(true)
        allow(derived_data).to receive(:executions).and_return([execution0, execution1])
        [execution0, execution1].each do |execution|
          allow(execution).to receive(:invalid?).and_return(false)
          allow(execution).to receive(:location).and_return(location)
        end
      end

      context 'with slow execution' do
        let(:time0) { 49.9 }
        let(:time1) { 50 }
        it 'asserts warning' do
          @xcprofiler.report(product_name)
          expect(@dangerfile).to have_received(:warn).with('`doSomething()` takes 50.0 ms to build',
                                                           file: 'path/to/Source.swift',
                                                           line: 20)
        end
      end

      context 'with very slow execution' do
        it 'asserts failure' do
          @xcprofiler.report(product_name)
          expect(@dangerfile).to have_received(:fail).with('`doSomething()` takes 100.0 ms to build',
                                                           file: 'path/to/Source.swift',
                                                           line: 20)
        end
      end

      context 'with threshold' do
        before do
          @xcprofiler.thresholds = {
            warn: 10,
            fail: 20
          }
        end

        context 'with slow execution' do
          let(:time0) { 100 }
          let(:time1) { 10 }
          it 'asserts warning' do
            @xcprofiler.report(product_name)
            expect(@dangerfile).to have_received(:warn).with('`doSomething()` takes 10.0 ms to build',
                                                             file: 'path/to/Source.swift',
                                                             line: 20)
          end
        end

        context 'with very slow execution' do
          let(:time0) { 9.9 }
          let(:time1) { 20 }
          it 'asserts failure' do
            @xcprofiler.report(product_name)
            expect(@dangerfile).to have_received(:fail).with('`doSomething()` takes 20.0 ms to build',
                                                             file: 'path/to/Source.swift',
                                                             line: 20)
          end
        end
      end

      context 'with inline_mode = false' do
        before do
          @xcprofiler.inline_mode = false
        end

        context 'with slow execution' do
          let(:time0) { 49.9 }
          let(:time1) { 50 }
          it 'asserts warning' do
            @xcprofiler.report(product_name)
            expect(@dangerfile).to have_received(:warn)
              .with('[Source.swift] `doSomething()` takes 50.0 ms to build', {})
          end
        end

        context 'with very slow execution' do
          it 'asserts failure' do
            @xcprofiler.report(product_name)
            expect(@dangerfile).to have_received(:fail)
              .with('[Source.swift] `doSomething()` takes 100.0 ms to build', {})
          end
        end
      end
    end
  end
end
