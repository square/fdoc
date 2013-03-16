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
        endpoint.should     be_kind_of(Fdoc::Endpoint)
        endpoint.should_not be_kind_of(Fdoc::EndpointScaffold)
      end
    end

    context "in scaffold mode" do
      let(:scaffold_mode) { true }

      it "returns an EndpointScaffold object" do
        subject.open(verb, path, scaffold_mode).should be_kind_of(Fdoc::EndpointScaffold)
      end
    end
  end

  describe "#path_for" do
    let(:flat_file_name) { File.expand_path('spec/fixtures/members/list-GET.fdoc') }
    let(:nested_file_name) { File.expand_path('spec/fixtures/members/list/GET.fdoc') }

    context "when a flat named filename exists" do
      before do
        File.should_receive(:exist?).with(flat_file_name).and_return(true)
      end

      it "returns the flat named file path" do
        subject.path_for(verb, path).should == flat_file_name
      end
    end

    context "when a no flat named named file exists, but a nested path does" do
      before do
        File.should_receive(:exist?).with(flat_file_name).and_return(false)
        File.should_receive(:exist?).with(nested_file_name).and_return(true)
      end

      it "returns the nested named file path" do
        subject.path_for(verb, path).should == nested_file_name
      end
    end

    context "when no file exists" do
      before do
        File.stub(:exist?).and_return(false)
      end

      it "returns the flat named file path" do
        subject.path_for(verb, path).should == flat_file_name
      end
    end
  end
end
