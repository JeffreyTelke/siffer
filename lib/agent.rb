module Siffer
  
  class Agent
    include Siffer::Protocol
    include Siffer::Messaging
    
    attr_reader :name, :host, :port
    
    def initialize(options = {})
      @name = options[:name] || "Default Agent"
      @host = options[:host] || "localhost"
      @port = options[:port] || 8300
    end
    
    def call(env)
      @request = Request.new(env)
      check_content_type_against_messaging
      check_path_against_protocol
      build_message_from_request
      @response = Response.new(Siffer::Messages::Ack.new(self.name,@message))
      @response.finish
    end
   
  end
  
end