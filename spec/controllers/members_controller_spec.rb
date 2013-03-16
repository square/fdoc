require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require 'rails-api'
require File.expand_path('../dummy_rails3.2_api/config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'fdoc/spec_watcher'


Fdoc.service_path = File.expand_path('../spec/fixtures')

describe MembersController do
  include Fdoc::SpecWatcher

  context "#show", :fdoc => "members/list" do
    it "can take an offset" do
      get :show, {
        :offset => 5
      }
    end
  end
end
