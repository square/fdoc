# encoding: utf-8

Gem::Specification.new do |s|
  s.name = "fdoc"

  s.version = File.read("#{File.dirname(__FILE__)}/VERSION")
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = "1.3.7"

  s.authors = ["Matt Wilson", "Zach Margolis", "Sean Sorrell"]
  s.email = "support@squareup.com"

  s.date = "2011-11-07"
  s.description = "A tool for documenting API endpoints."
  s.summary = "A tool for documenting API endpoints."
  s.homepage = "http://github.com/square/fdoc"

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.require_paths = ["lib"]
  s.files = Dir['{lib,spec}/**/*'] + %w(fdoc.gemspec Rakefile README.md Gemfile)
  s.test_files = Dir['spec/**/*']
  s.bindir        = "bin"
  s.executables  << "fdoc"

  s.add_dependency("json")
  s.add_dependency("json-schema", ">= 1.0.1")
  s.add_dependency("kramdown")
  s.add_dependency("thor")

  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", "~> 2.5")
  s.add_development_dependency("nokogiri")
  s.add_development_dependency("cane")
  s.add_development_dependency("guard-rspec")
end
