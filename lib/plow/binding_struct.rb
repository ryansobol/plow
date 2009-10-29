# encoding: UTF-8

class Plow
  # A small class that provides Struct-like access to instance variables, but in in a far more simple internal implementation.
  # useful for ERB templates.
  #
  # @see http://www.ruby-doc.org/ruby-1.9/classes/Binding.html
  # @see http://www.ruby-doc.org/ruby-1.9/classes/ERB.html
  # @see http://www.ruby-doc.org/ruby-1.9/classes/Struct.html
  class BindingStruct
    
    # Creates a new `BindingStruct` from a `Hash` object where each key/value pair is an instance variable within the object.
    #
    # @param [Hash] hash A basic `Hash` object
    # @example Usage
    #   bstruct = Plow::BindingStruct.new({first_name: 'Carl', last_name: 'Sagan'})
    #   bstruct.instance_variable_get("@first_name")  #=> 'Carl'
    #   bstruct.instance_variable_get("@last_name")   #=> 'Sagan'
    def initialize(hash)
      hash.each_pair do |name, val|
        instance_variable_set("@#{name}".to_sym, val)
      end
    end
    
    # Returns an internal `Binding` object
    #
    # @return [Binding] An internal `Binding` object
    # @see http://www.ruby-doc.org/ruby-1.9/classes/Binding.html
    def get_binding
      binding
    end
  end
end
