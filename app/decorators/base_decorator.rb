class BaseDecorator < SimpleDelegator
  def self.decorate(object)
    return nil if object.nil?

    if object.respond_to?(:map)
      object.map { |o| new(o) }
    else
      new(object)
    end
  end

  def decorated?
    true
  end

  def object
    __getobj__
  end
end
