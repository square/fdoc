require 'spec_helper'
require 'nokogiri'

describe Fdoc::MetaServicePresenter do
  subject {
    Fdoc::MetaServicePresenter.new(Fdoc::MetaService.new('spec/fixtures'))
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
      markdown.should include "* PUT [https:&#8203;/&#8203;/api.sample.com&#8203;/members&#8203;/add](members_api/add-PUT.md)"
      markdown.should include "* POST [https:&#8203;/&#8203;/api.sample.com&#8203;/members&#8203;/draft](members_api/draft-POST.md)"
    end
  end

  context "#relative_service_path" do
    let(:service) { subject.services.first }

    it "returns relative path" do
      subject.relative_service_path(service).should == "members_api"
    end

    it "should join relative path if passed in a filename" do
      subject.relative_service_path(service, 'index.md').should == "members_api/index.md"
    end
  end
end
