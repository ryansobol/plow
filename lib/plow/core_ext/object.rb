class Object
  # See http://api.rubyonrails.org/classes/Object.html#M000279
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end