class Object
  def empty?
    (self == nil) || (self.respond_to?(:length) && self.length == 0)
  end
  def present?
    !empty?
  end
end
