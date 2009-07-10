module Siffer
  module Messages
    
    # This class is used as the base for all SIF common types.
    class SifXml < Siffer::Xml::Body
      private
      
      # Overriden to prefix SIF to the element name
      def element_name(name = self.class)
        "SIF_#{name.to_s.split("::").last.camelize}"
      end
    end
        
    # Security Element for the Header Element 
    #@see Header
    class Security < SifXml
      element :secure_channel, :type => :mandatory
    end
    
    # SecureChannel Element for the Security Element
    #@see Security
    class SecureChannel < SifXml
      element :authentication_level, :type => :mandatory
      element :encryption_level, :type => :mandatory
    end
    
    # List of Contexts for the Message
    class Contexts < SifXml
      element :context, :type => :mandatory
    end
    
    # Header for all SIF_Message types
    #@see Message
    class Header < SifXml
      element :msg_id, :type => :mandatory
      element :timestamp, :type => :mandatory
      element :security
      element :source_id, :type => :mandatory
      element :destination_id
      element :contexts
      
      # Overloaded to provide defaults for Security, MsgId and Timestamp
      def initialize(values ={})
        if values.keys.include?(:authentication_level) and values.keys.include?(:encryption_level)
          secure_channel = SecureChannel.new(values)
        else
          secure_channel = SecureChannel.new(:authentication_level => 0, :encryption_level => 0)
        end
        security = Security.new(:secure_channel => secure_channel)
        super({:source_id => values[:source_id], 
              :msg_id => UUID.generate(:compact).upcase,
              :timestamp => Time.now,
              :security => security}.merge(values))
      end
    end
    
    # Base Message for all SIF_Message types
    #@see Ack
    #@see Event
    #@see Provide
    #@see Provision
    class Message < SifXml
      attribute :xmlns, Siffer.sif_xmlns
      attribute :version, Siffer.sif_version
      element :header, :type => :mandatory
      
      # Inspects values for :source_id and if exists injects new Header
      def initialize(values = {})
        if values.keys.include?(:source_id)
          values[:header] = Header.new(values)
        end
        super(values)
      end
      
      class << self
        def declared_values
          declared = []
          declared << instance_variable_get("@declared_values") unless instance_variable_get("@declared_values").nil?
          if !instance_of?(Message) && superclass == Message
            declared << superclass.instance_variable_get("@declared_values") unless superclass.instance_variable_get("@declared_values").nil?
          end
          declared.flatten
        end
      end
      
      # Overriden to check for subclassing
      def declared_values
        declared = super
        if subclass_of_message
          declared << self.class.superclass.instance_variable_get("@declared_values") unless self.class.superclass.instance_variable_get("@declared_values").nil?
        end
        declared.flatten  
      end
      
      # Overriden to check for subclassing
      def mandatory
        mandated = super
        if subclass_of_message
          mandated << self.class.superclass.instance_variable_get("@mandatory") unless self.class.superclass.instance_variable_get("@mandatory").nil?
        end
        mandated.flatten
      end
      
      # Overriden to check for subclassing
      def conditional
        conditioned = super
        if subclass_of_message
          conditioned.update self.class.superclass.instance_variable_get("@conditional") unless self.class.superclass.instance_variable_get("@conditional").nil?
        end
        conditioned
      end
      
      private
      
      # Writes the elements and attributes to a SIF specific XML string
      def write_body(xml)
        if subclass_of_message
          super_attrs = camelized_attributes(self.class.superclass.instance_variable_get("@attributes"))
          args = (super_attrs.nil?) ? element_name(self.class.superclass) : [element_name(self.class.superclass), super_attrs]
          xml.tag!(*args) { |body| super(body) }
        else
          super(xml)
        end
      end
      
      # Returns true if this instance is not a Message and its
      # parent class is a Message.
      def subclass_of_message
        !self.instance_of?(Message) && self.class.superclass == Message
      end
      
    end

  end
end