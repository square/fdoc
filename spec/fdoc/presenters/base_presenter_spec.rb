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
      expect(File).to receive(:exists?).with('templates/test.html.erb').and_return(false)
      allow(File).to receive(:read).and_return('test content')
      subject.to_html
    end

    it "renders from local template directory" do
      expect(File).to receive(:exists?).with('templates/test.html.erb').and_return(true)
      expect(File).to receive(:read).with('templates/test.html.erb').and_return('test content')
      subject.to_html
    end
  end
end
