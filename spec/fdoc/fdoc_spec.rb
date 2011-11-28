path = File.expand_path(File.dirname(__FILE__))
require "#{path}/../spec_helper"

describe Fdoc do
  subject { described_class }
  
  let(:known_method) { "list" }
  let(:unknown_method) { "remove" }
  let(:controller) { "Api::MembersController" }
  let(:unknown_controller) { "Api::UnknownController" }
  
  before { subject.load(FIXTURE_PATH)  }
  
  describe "#checklist_for" do
    context "when a controller has not been documented" do
      it "returns nil" do
        subject.checklist_for(unknown_controller, known_method).should be_nil
      end
    end
    
    context "when a controller has been documented" do
      context "when a method does exist" do
        it "returns a checklist for that method" do
          subject.checklist_for(controller, known_method).should be_kind_of Fdoc::MethodChecklist
        end
      end

      context "when a method does not exist" do
        it "raises an UndocumentedMethodError" do
          expect { subject.checklist_for(controller, unknown_method) }.to raise_exception(Fdoc::UndocumentedMethodError)
        end
      end
    end  
  end


  describe "#scaffold_for" do  
    context "when a controller has not been documented" do
      it "scaffolds the controller" do
        subject.checklist_for(unknown_controller, known_method).should be_nil
        subject.scaffold_for(unknown_controller, known_method).should be_kind_of Fdoc::MethodScaffold
        subject.checklist_for(unknown_controller, known_method).should_not be_nil
      end
    end
      
    context "when a controller has been documented" do
      context "when a method or scaffold does not exist" do
        it "scaffolds the method" do
          expect { subject.checklist_for(controller, unknown_method) }.to raise_exception(Fdoc::UndocumentedMethodError)
          subject.scaffold_for(controller, unknown_method).should be_kind_of Fdoc::MethodScaffold
        end
      end

      context "when a method or scaffold does exist" do
        it "scaffolds the method" do
          expect { subject.checklist_for(controller, known_method) }.not_to raise_exception(Fdoc::UndocumentedMethodError)
          subject.scaffold_for(controller, known_method).should be_kind_of Fdoc::MethodScaffold
        end
      end
    end
  end
end