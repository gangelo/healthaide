module ComponentHelper
  # Form input helper
  def form_input(form, field, **options)
    error = if form.object.respond_to?(:errors)
              form.object.errors[field].first
    else
              options.delete(:error)
    end

    render "components/forms/input",
           form: form,
           field: field,
           error: error,
           **options
  end

  # Button helper
  def button(text, **options)
    render "components/buttons/button",
           text: text,
           **options
  end

  # Card helper
  def card(**options, &block)
    render "components/cards/card", **options, &block
  end

  # Common button variants
  def primary_button(text, **options)
    button(text, variant: :primary, **options)
  end

  def secondary_button(text, **options)
    button(text, variant: :secondary, **options)
  end

  def danger_button(text, **options)
    button(text, variant: :danger, **options)
  end

  def success_button(text, **options)
    button(text, variant: :success, **options)
  end

  # Common form input types
  def text_input(form, field, **options)
    form_input(form, field, type: :text, **options)
  end

  def textarea_input(form, field, **options)
    form_input(form, field, type: :textarea, **options)
  end

  def select_input(form, field, options, **html_options)
    form_input(form, field, type: :select, options: options, **html_options)
  end

  # Common card layouts
  def info_card(title, **options, &block)
    card(title: title, class: "bg-blue-50", **options, &block)
  end

  def warning_card(title, **options, &block)
    card(title: title, class: "bg-yellow-50", **options, &block)
  end

  def error_card(title, **options, &block)
    card(title: title, class: "bg-red-50", **options, &block)
  end

  def success_card(title, **options, &block)
    card(title: title, class: "bg-green-50", **options, &block)
  end
end
