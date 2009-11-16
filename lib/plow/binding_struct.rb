# encoding: UTF-8

class Plow
  # `BindingStruct` is an **adapter** between the friendly declarative-style of `Hash` key/value
  # pairs and the built-in, `ERB` (i.e. embedded ruby) class, which takes an optional `Binding`
  # object for the scope of template evaluation.  
  #
  # This class is very similar to Ruby's built-in `OpenStruct` class.  It differs internally as
  # `BindingStruct` converts each element of the `Hash` object into an instance variable during
  # initialization.  Once initialized, an instance of `BindingStruct` is able to return a
  # reference to it's internal `Binding` object.  This object can be further passed along to an
  # `ERB` object for evaluation within a template.
  #
  # @example Sample template file at /path/to/a/template/file.txt'
  #   <%= @first_name %> <%= @last_name %> invented the Universe.
  #
  # @example Evaluating an `ERB` template file with a `BindingStruct` context
  #   template = ERB.new(File.read('/path/to/a/template/file.txt'))
  #   context  = Plow::BindingStruct.new({ first_name: 'Carl', last_name: 'Sagan' })
  #   result   = template.result(context.get_binding)  #=> Carl Sagan invented the Universe.
  #
  # @see http://www.ruby-doc.org/ruby-1.9/classes/Binding.html
  # @see http://www.ruby-doc.org/ruby-1.9/classes/ERB.html
  # @see http://www.ruby-doc.org/ruby-1.9/classes/OpenStruct.html
  class BindingStruct
    
    # Creates a new `BindingStruct` from a `Hash` where each key/value pair is converted to an
    # instance variable.
    #
    # @param [Hash] source A source of data
    # @example A peek into the internals of an instance post initialization
    #   bstruct = Plow::BindingStruct.new({first_name: 'Carl', last_name: 'Sagan'})
    #   bstruct.instance_variables.sort              #=> [:@first_name, :@last_name]
    #   bstruct.instance_variable_get(:@first_name)  #=> 'Carl'
    #   bstruct.instance_variable_get(:@last_name)   #=> 'Sagan'
    def initialize(source)
      source.each_pair do |name, val|
        instance_variable_set("@#{name}".to_sym, val)
      end
    end
    
    # Returns a reference to its internal `Binding` which can be used in conjunction with `ERB`
    # template evaluation.
    #
    # @return [Binding] An reference to its internal `Binding`
    # @see http://www.ruby-doc.org/ruby-1.9/classes/Binding.html
    def get_binding
      binding
    end
  end
end
