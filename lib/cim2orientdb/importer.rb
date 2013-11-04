#
# cim2orientdb/lib/cim2orientdb/importer.rb
#
# Importer of cim class structures as OrientDB classes
#

require 'mof'
require 'cim'

module CIM2OrientDB
  class Importer

    def initialize client
      @client = client
    end # initialize

    # save instance (or objectpath)
    def save element
      puts "Import.save #{element}<#{element.class}"
      element.properties.each do |prop|
        # document
      end
    end
    
    # create class hierachy
    def get_class klass
      begin
        @client.get_class klass
        true
      rescue Orientdb4r::NotFoundError
        # return nil
      end
    end
    
    def create_class mof
      puts "create_class #{mof.name}"
      properties = Array.new
      mof.features.each do |prop|
        p = Hash.new
        p[:property] = prop.name
        if prop.key?
          p[:mandatory] = true 
          p[:notnull] = true
        end
        p[:type] = case prop.type.type
                   when :string
                     :string
                   when :uint64, :uint32, :uint16, :uint8
                     :decimal
                   when :int64
                     :long
                   when :int32
                     :integer
                   when :int16
                     :short
                   when :int8
                     :byte
                   else
                     abort "Type #{prop.type} unsupported"
                   end
        options = Hash.new
        options[:properties] = properties
        options[:extends] = mof.superclass if mof.superclass
        options[:abstract] = true if mof.name =~ /^CIM_/
        begin
          @client.create_class mof.name, options
        rescue Exception => e
          unless e.to_s =~ /already exists/
            puts "Class creation failed with #{e.class}:#{e}"
          end
        end
      end
    end
  end
end
