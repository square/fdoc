require 'spec_helper'
require 'nokogiri'

describe Fdoc::SchemaPresenter do
  let(:schema) {
    {
      'description' => 'Some description text',
      'example' => 'an example'
    }
  }
  subject {
    Fdoc::SchemaPresenter.new(schema, {})
  }

  context '#to_html' do
    it 'should generate valid HTML' do
      html = subject.to_html

      html.should include 'Some description text'
      html.should include 'an example'
      expect {
        Nokogiri::HTML(html) { |config| config.strict }
      }.to_not raise_exception
    end
  end

  context "#to_markdown" do
    it "should generate markdown" do
      markdown = subject.to_markdown
      markdown.should include 'Some description text'
      markdown.should include 'an example'
    end
  end
end
