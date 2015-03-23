require 'spec_helper'

describe Fdoc::Service do
  subject { described_class.new('spec/fixtures') }

  let(:verb) { 'GET' }
  let(:path) { 'members/list' }

  describe "#open" do
    let(:scaffold_mode) { false }
    context "in regular mode" do
      it "returns an Endpoint object" do
        endpoint = subject.open(verb, path, scaffold_mode)
        expect(endpoint).to     be_kind_of(Fdoc::Endpoint)
        expect(endpoint).not_to be_kind_of(Fdoc::EndpointScaffold)
      end
    end

    context "in scaffold mode" do
      let(:scaffold_mode) { true }

      it "returns an EndpointScaffold object" do
        expect(subject.open(verb, path, scaffold_mode)).to be_kind_of(Fdoc::EndpointScaffold)
      end
    end
  end

  describe "#path_for" do
    let(:flat_file_name) { File.expand_path('spec/fixtures/members/list-GET.fdoc') }
    let(:nested_file_name) { File.expand_path('spec/fixtures/members/list/GET.fdoc') }

    context "when a flat named filename exists" do
      before do
        expect(File).to receive(:exist?).with(flat_file_name).and_return(true)
      end

      it "returns the flat named file path" do
        expect(subject.path_for(verb, path)).to eq(flat_file_name)
      end
    end

    context "when a no flat named named file exists, but a nested path does" do
      before do
        expect(File).to receive(:exist?).with(flat_file_name).and_return(false)
        expect(File).to receive(:exist?).with(nested_file_name).and_return(true)
      end

      it "returns the nested named file path" do
        expect(subject.path_for(verb, path)).to eq(nested_file_name)
      end
    end

    context "when no file exists" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "returns the flat named file path" do
        expect(subject.path_for(verb, path)).to eq(flat_file_name)
      end
    end
  end
end