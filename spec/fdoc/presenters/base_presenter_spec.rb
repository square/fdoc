require 'spec_helper'
require 'nokogiri'

describe Fdoc::BasePresenter do
  class Fdoc::SamplePresenter < Fdoc::BasePresenter
    def to_html
      render_erb('test.html.erb')
    end
  end

  subject {
    Fdoc::SamplePresenter.new template_directory: 'templates'
  }

  context "#render_erb" do
    it "renders a default template" do
      File.should_receive(:exists?).with('templates/test.html.erb').and_return(false)
      File.stub(:read).and_return('test content')
      subject.to_html
    end

    it "renders from local template directory" do
      File.should_receive(:exists?).with('templates/test.html.erb').and_return(true)
      File.should_receive(:read).with('templates/test.html.erb').and_return('test content')
      subject.to_html
    end
  end
end
