class Plow
  class BindingStruct
    def initialize(hash)
      hash.each_pair do |name, val|
        instance_variable_set("@#{name}".to_sym, val.clone)
      end
    end

    def get_binding
      binding
    end
  end
end
