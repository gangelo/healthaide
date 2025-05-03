module DecoratorHelper
  def decorate(object, decorator_class = nil)
    return object if object.nil? || (object.respond_to?(:decorated?) && object.decorated?)

    decorator_class ||= "#{object.class.name}Decorator".constantize
    decorator_class.decorate(object)
  end
end
