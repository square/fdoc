require 'spec_helper'

require 'fdoc/spec_watcher'

describe Fdoc::SpecWatcher do

  context "on rails" do
    before do
      # This should be an integration test, but for now a smoke test suffices to
      # surface obvious bugs and verify some behaviours.
      @klass = Class.new do
        def example
          Struct.new(:metadata).new(:fdoc => 'index')
        end

        def response
          Struct.new(:body, :status).new("{}", 200)
        end

        def get(action, params)
          params
        end
      end.new
      @klass.extend(Fdoc::SpecWatcher)
    end

    it 'should verify when params are a hash', fdoc: 'index' do
      expect(Fdoc::Service).to receive(:verify!) do |*args|
        expect(args[2]).to eq({ :id => 1 })
      end
      @klass.get(:index, {:id => 1})
    end

    it 'should verify when params are JSON', fdoc: 'index' do
      expect(Fdoc::Service).to receive(:verify!) do |*args|
        expect(args[2]).to eq({'id' => 1 })
      end
      @klass.get(:index, {:id => 1}.to_json)
    end
  end

  context "on sinatra" do

    before do
      # This should be an integration test, but for now a smoke test suffices to
      # surface obvious bugs and verify some behaviours.
      @klass = Class.new do
        def example
          Struct.new(:metadata).new(:fdoc => 'index')
        end

        def last_response
          Struct.new(:body, :status).new("{}", 200)
        end

        def get(action, params)
          params
        end
      end.new
      @klass.extend(Fdoc::SpecWatcher)
    end

    it 'should verify when params are a hash', fdoc: 'index' do
      expect(Fdoc::Service).to receive(:verify!)do |*args|
        expect(args[2]).to eq({ :id => 1 })
      end
      @klass.get("/", {:id => 1})
    end

    it 'should verify when params are JSON', fdoc: 'index' do
      expect(Fdoc::Service).to receive(:verify!) do |*args|
        expect(args[2]).to eq({ 'id' => 1})
      end
      @klass.get("/", {:id => 1}.to_json)
    end
  end

  it 'should override the existing HTTP verb methods' do
    klass = Class.new do
      include Fdoc::SpecWatcher
    end.new
    [:get, :post, :put, :patch, :delete].each do |verb|
      klass.method(verb).owner.should be Fdoc::SpecWatcher
    end
  end
end
