require File.join(File.dirname(__FILE__), "spec_helper")

describe Siffer::Server do  
  it "should instantiate with default host, port, name" do
    server = Siffer::Server.new
    server.host.should == "localhost"
    server.port.should == 8300
    server.name.should == "Default Server"
  end
  
  it "should respond to uri" do
    server = Siffer::Server.new
    server.uri.should == "http://localhost:8300"
  end
end