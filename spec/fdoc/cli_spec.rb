require "spec_helper"

describe Fdoc::Cli do
  let(:fixtures_path) { File.expand_path("../../fixtures", __FILE__) }
  let(:temporary_path) { Dir.mktmpdir("fdoc-cli") }
  let(:fdoc_path) { File.expand_path("fdoc", temporary_path) }
  let(:html_path) { File.expand_path("html", temporary_path) }
  let(:options) { {} }

  subject(:cli) { Fdoc::Cli.new([fdoc_path], options) }

  before { FileUtils.mkdir_p(fdoc_path) }

  around { |e| capture(:stdout, &e) }

  def with_fixture(fixture_file, destination_file = nil)
    destination = File.expand_path(destination_file || fixture_file, fdoc_path)
    FileUtils.mkdir_p(File.dirname(destination))
    source = File.expand_path(fixture_file, fixtures_path)
    FileUtils.cp(source, destination)
  end

  describe "#convert" do
    let(:styles_css_path) { File.expand_path("styles.css", html_path) }

    context "when the fdoc path does not exist" do
      before { FileUtils.rmdir(fdoc_path) }

      it "raises an exception" do
        expect do
          cli.convert(fdoc_path)
        end.to raise_exception(Fdoc::NotFound)
      end
    end

    context "when the fdoc path exists" do
      context "when the destination does not exist" do
        it "makes a destination directory" do
          expect do
            cli.convert(fdoc_path)
          end.to change { File.directory?(html_path) }.to(true)
        end
      end

      context "when the destination exists as a file" do
        before { FileUtils.touch(html_path) }

        it "raises an exception" do
          expect do
            cli.convert(fdoc_path)
          end.to raise_exception(Fdoc::NotADirectory)
        end
      end

      it "copies the css to the destination" do
        expect do
          cli.convert(fdoc_path)
        end.to change { File.exist?(styles_css_path) }.from(false)
      end

      context "when there is a meta service fdoc" do
        let(:root_html) { File.expand_path("index.html", html_path) }
        let(:members_html) do
          File.expand_path("members_api/index.html", html_path)
        end
        let(:endpoint_html) do
          File.expand_path("members_api/add-PUT.html", html_path)
        end

        before { with_fixture("sample_group.fdoc.meta") }

        context "when no service fdoc exists" do
          specify { expect { cli.convert(fdoc_path) }.to raise_error }
        end

        context "when a service fdoc exists" do
          before { with_fixture("members/members.fdoc.service") }

          it "creates a root-level html file" do
            expect do
              cli.convert(fdoc_path)
            end.to change { File.exist?(root_html) }.from(false)
          end

          it "writes the service-level html file" do
            expect do
              cli.convert(fdoc_path)
            end.to change { File.exist?(members_html) }.from(false)
          end

          context "when an endpoint fdoc exists" do
            before { with_fixture("members/add-PUT.fdoc") }

            it "writes the endpoint html file" do
              expect do
                cli.convert(fdoc_path)
              end.to change { File.exist?(endpoint_html) }.from(false)
            end
          end
        end
      end

      context "when there is no meta service fdoc" do
        let(:root_html) { File.expand_path("index.html", html_path) }
        let(:endpoint_html) do
          File.expand_path("add-PUT.html", html_path)
        end

        context "when no service fdoc exists" do
          it "creates a dummy index" do
            expect do
              cli.convert(fdoc_path)
            end.to change { File.exist?(root_html) }.from(false)
          end
        end

        context "when a service fdoc exists" do
          before do
            with_fixture("members/members.fdoc.service", "a.fdoc.service")
          end

          it "writes the service-level html file" do
            expect do
              cli.convert(fdoc_path)
            end.to change { File.exist?(root_html) }.from(false)
          end

          context "when an endpoint fdoc exists" do
            before { with_fixture("members/add-PUT.fdoc", "add-PUT.fdoc") }

            it "writes the endpoint html file" do
              expect do
                cli.convert(fdoc_path)
              end.to change { File.exist?(endpoint_html) }.from(false)
            end
          end
        end
      end
    end
  end

  describe "accessors" do
    before do
      subject.origin_path = fdoc_path
      subject.destination_root = html_path
    end

    context "by default" do
      it { should_not have_meta_service }
      its(:service_presenters) { should have(1).service }
      its(:output_path) { should =~ /html$/ }
    end

    context "when an output path is specified" do
      let(:output_option) { "/a/path/for/html" }
      let(:options) { {:output => output_option} }

      its(:output_path) { should == output_option }
    end

    context "when a meta service file exists" do
      before { with_fixture("sample_group.fdoc.meta") }

      it { should have_meta_service }
      its(:service_presenters) { should have(1).service }
    end

    context "when the origin is a directory" do
      it { should have_valid_origin }
    end

    context "when the origin does not exist" do
      before { FileUtils.rmdir(fdoc_path) }

      it { should_not have_valid_origin }
    end

    context "when the origin is not a directory" do
      before do
        FileUtils.rmdir(fdoc_path)
        FileUtils.touch(fdoc_path)
      end

      it { should_not have_valid_origin }
    end

    context "when the destination does not exist" do
      it { should have_valid_destination }
    end

    context "when the destination is a directory" do
      before { FileUtils.mkdir_p(html_path) }

      it { should have_valid_destination }
    end

    context "when the destination is not a directory" do
      before { FileUtils.touch(html_path) }

      it { should_not have_valid_destination }
    end
  end

  describe "#html_options" do
    let(:html_path) { "/a/great/place/to/keep/html"}

    before { subject.destination_root = html_path }

    its(:html_options) { should include(:static_html => true) }
    its(:html_options) { should include(:html_directory => html_path) }

    context "when url_base_path is not provided" do
      its(:html_options) { should include(:url_base_path => nil) }
    end

    context "when url_base_path is provided" do
      let(:url_base_path) { "totally/not/like/a/wsdl" }
      let(:options) { {:url_base_path => url_base_path} }

      its(:html_options) { should include(:url_base_path => url_base_path) }
    end
  end

  describe "#inside_service" do
    let(:presenter) { cli.service_presenters.first }

    before do
      subject.origin_path = fdoc_path
      subject.destination_root = html_path
    end

    context "when there is a meta service" do
      before do
        with_fixture("sample_group.fdoc.meta")
        with_fixture("members/members.fdoc.service")
      end

      it "leaves the output directory" do
        cli.inside_service_presenter(presenter) do
          Dir.pwd.should =~ %r|#{html_path}/members_api$|
        end
      end
    end

    context "when there is a single service" do
      before do
        with_fixture("members/members.fdoc.service", "members.fdoc.service")
      end

      it "does not leave the output directory" do
        cli.inside_service_presenter(presenter) do
          Dir.pwd.should =~ /#{html_path}$/
        end
      end
    end
  end
end
