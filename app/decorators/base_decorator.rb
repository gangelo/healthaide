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

  # Support for Rails' polymorphic path generation
  def model_name
    object.class.model_name
  end

  # Support for polymorphic routes
  def to_model
    object
  end

  # Ensure decorator doesn't break class inheritance checks
  def kind_of?(klass)
    object.kind_of?(klass) || super
  end
  alias_method :is_a?, :kind_of?

  # Make decorator work with form_for and other Rails path helpers
  def to_param
    object.to_param
  end
end
