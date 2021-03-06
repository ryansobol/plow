# encoding: UTF-8

# Mindfully expanding the base `Object` class with sensible methods.
class Object
  # An object is blank if it‘s false, empty, or a whitespace string. 
  # For example, "", " ", nil, [], and {} are blank.
  # 
  # @example This simplifies
  #   if !address.nil? && !address.empty?
  # @example to
  #   if !address.blank?
  # @see http://api.rubyonrails.org/classes/Object.html#M000279
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end