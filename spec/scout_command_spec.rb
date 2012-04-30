require "spec_helper"
require "scout_command"

describe ScoutCommand do
  subject { instance }
  let(:instance) { described_class.new(node) }
  let(:key) { "key" }
  let(:name) { nil }
  let(:options) { {} }
  let(:node_name) { "i-12345678" }
  let(:node_environment) { "_default" }
  let(:rvm_ruby) { nil }

  let :node do
    {
      "chef_environment" => node_environment,
      "name" => node_name,
      "scout" => {
        "key" => key,
        "name" => name,
        "options" => options,
        "rvm_ruby" => rvm_ruby,
      },
    }
  end

  shared_examples_for "raises when no key is given" do
    context "when no key is given" do
      let(:key) { nil }
      it { expect { subject }.to raise_error described_class::MissingKeyError }
    end
  end

  describe "#to_s" do
    subject { instance.to_s }
    include_examples "raises when no key is given"

    context "no special options" do
      it "executes scout and gives it the key" do
        should == "scout #{key}"
      end
    end

    context "with a name" do
      let(:name) { %{My 'Killer' Server} }

      it "uses the escape name arguments" do
        should == %{scout #{key} --name 'My \\'Killer\\' Server'}
      end
    end

    context "with a name with a replaced value" do
      let(:name) { "Role Based Name (%{name})" }

      it "interpolates the embedded name" do
        should == %{scout #{key} --name 'Role Based Name (#{node_name})'}
      end
    end

    context "with rvm_ruby set" do
      let(:rvm_ruby) { "ruby-1.9.2-p318@scout" }

      it "uses the rvm wrapper" do
        should == %{/usr/local/rvm/bin/scout_scout #{key}}
      end
    end
  end

  describe "#rvm?" do
    subject { instance.rvm? }

    context "rvm_ruby not set" do
      it { should be_false }
    end

    context "rvm_ruby is set" do
      let(:rvm_ruby) { "ruby-1.9.2-p318@scout" }
      it { should be_true }
    end
  end

  describe "executable" do
    subject { instance.executable }

    context "rvm_ruby not set" do
      it { should == "scout" }
    end

    context "rvm_ruby is set" do
      let(:rvm_ruby) { "ruby-1.9.2-p318@scout" }
      it { should == "/usr/local/rvm/bin/scout_scout" }
    end
  end

  describe "#key" do
    subject { instance.key }
    include_examples "raises when no key is given"

    it "uses the key in the node attributes" do
      should == key
    end
  end

  describe "#arguments" do
    subject { instance.arguments }

    context "when there are no extra options" do
      it { should == "" }
    end

    context "when options are provided" do
      let :options do
        {
          "server" => "http://scout.example.com/",
          "level" => "debug",
          "http-proxy" => "http://proxy.example.com/",
        }
      end

      it "serializes the provided options" do
        should == %{--server 'http://scout.example.com/' --level 'debug' --http-proxy 'http://proxy.example.com/'}
      end
    end

    context "when a name is provided" do
      let(:name) { "My Server" }

      it "includes the name" do
        should == %{--name 'My Server'}
      end
    end

    context "when the name has a single quore in it" do
      let(:name) { %{My 'Killer' Server} }

      it "escapes the single quotes" do
        should == %{--name 'My \\'Killer\\' Server'}
      end
    end

    context "when both options and a name are provided" do
      let(:name) { "My Server" }

      let :options do
        {
          "server" => "http://scout.example.com/",
          "level" => "debug",
          "http-proxy" => "http://proxy.example.com/",
        }
      end

      it "includes the name" do
        should include %{--name 'My Server'}
      end

      it "includes the options" do
        should include %{--server 'http://scout.example.com/' --level 'debug' --http-proxy 'http://proxy.example.com/'}
      end
    end
  end

  describe "#options" do
    subject { instance.options }

    context "when there are no extra options" do
      it { should == {} }
    end

    context "when options are provided" do
      let :options do
        {
          "server" => "http://scout.example.com/",
          "level" => "debug",
          "http-proxy" => "http://proxy.example.com/",
        }
      end

      it "returns the provided options" do
        should == options
      end
    end

    context "when a name is provided" do
      let(:name) { "My Server" }

      it "includes the name" do
        should == { "name" => name }
      end
    end

    context "when both options and a name are provided" do
      let(:name) { "My Server" }

      let :options do
        {
          "server" => "http://scout.example.com/",
          "level" => "debug",
          "http-proxy" => "http://proxy.example.com/",
        }
      end

      it "includes the name" do
        should include("name" => "My Server")
      end

      it "includes the options" do
        should include(options)
      end
    end
  end

  describe "#name" do
    subject { instance.name }

    context "no name" do
      it { should be_nil }
    end

    context %{My 'Killer' Server} do
      let(:name) { %{My 'Killer' Server} }
      it { should == name }
    end

    context "%{name}" do
      let(:name) { "%{name}" }

      it "uses the node name" do
        should == node_name
      end
    end

    context "embeds %{name}" do
      let(:name) { "Role Based Name (%{name})" }

      it "interpolates the embedded name" do
        should == "Role Based Name (#{node_name})"
      end
    end

    context "%{chef_environment}" do
      let(:name) { "%{chef_environment}" }

      it "uses the node environment" do
        should == node_environment
      end
    end
  end
end

describe ScoutCommand::MissingKeyError do
  it { should be_a_kind_of ArgumentError }
end
