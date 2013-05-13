require 'spec_helper'
require 'nokogiri'

describe Fdoc::ServicePresenter do
  subject {
    Fdoc::ServicePresenter.new(Fdoc::Service.new('spec/fixtures'))
  }

  context "#to_html" do
    it "should generate valid HTML" do
      html = subject.to_html

      expect {
        Nokogiri::HTML(html) { |config| config.strict }
      }.to_not raise_exception
    end
  end

  context "#to_markdown" do
    it "should generate markdown" do
      markdown = subject.to_markdown
      markdown.should include "* PUT [members&#8203;/add](members/add-PUT.md)"
      markdown.should include "* POST [members&#8203;/draft](members/draft-POST.md)"
    end
  end
end
