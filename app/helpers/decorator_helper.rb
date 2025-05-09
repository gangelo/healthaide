module DecoratorHelper
  def decorate(object, decorator_class = nil)
    return object if object.nil? || (object.respond_to?(:decorated?) && object.decorated?)

    # Handle ActiveRecord relations by mapping each record
    if object.is_a?(ActiveRecord::Relation) || object.is_a?(ActiveRecord::Associations::CollectionProxy)
      klass = object.klass
      decorator_class ||= compose_decorator_class(klass.name)

      return object.map { decorator_class.new(it) }
    end

    # Handle array of objects by mapping each item
    if object.is_a?(Array)
      return object if object.empty?

      first_obj = object.first
      if first_obj.is_a?(ActiveRecord::Base)
        klass = first_obj.class
        decorator_class ||= compose_decorator_class(klass.name)

        return object.map { decorator_class.new(it) }
      end
    end

    # Handle single object
    decorator_class ||= compose_decorator_class(object.class.name)
    decorator_class.decorate(object)
  end

  private

  def compose_decorator_class(klass_name)
    "#{klass_name}Decorator".constantize.new
  end
end
