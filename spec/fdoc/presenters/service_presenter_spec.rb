require 'spec_helper'
require 'nokogiri'

describe Fdoc::ServicePresenter do
  subject {
    Fdoc::ServicePresenter.new(Fdoc::Service.new('spec/fixtures/members'))
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
      markdown.should include "* PUT [https:&#8203;/&#8203;/api.sample.com&#8203;/members&#8203;/add](add-PUT.md)"
      markdown.should include "* POST [https:&#8203;/&#8203;/api.sample.com&#8203;/members&#8203;/draft](draft-POST.md)"
    end
  end

  context "#relative_meta_service_path" do
    let(:meta_service) { Fdoc::MetaServicePresenter.new(Fdoc::MetaService.new('spec/fixtures')) }
    before do
      subject.service.meta_service = meta_service
    end

    its(:relative_meta_service_path) { should == "../"}

    context "pass in filename" do
      it "should join with filename" do
        subject.relative_meta_service_path('index.md').should == "../index.md"
      end
    end
  end
end
