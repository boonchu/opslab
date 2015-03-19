require 'spec_helper'

describe package('java-1.7.0-openjdk') do
  it { should be_installed }
end

describe package('tomcat6') do
  it { should be_installed }
end

describe port(8080) do
  it { should be_listening }
end

describe file('/var/lib/tomcat6/webapps/punter.war') do
  it { should be_file }
end

describe file('/var/lib/tomcat6/webapps/punter') do
  it { should be_directory }
end

describe "Custom checking on tomcat apps" do
  it "is listening on port 8080" do
    expect(port(8080)).to be_listening
  end

  it "has a running service of tomcat6" do
    expect(service("tomcat6")).to be_running
  end
end
