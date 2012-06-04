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
end
