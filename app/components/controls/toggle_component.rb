module Controls
  class ToggleComponent < ViewComponent::Base
    attr_reader :id, :checked, :disabled, :label, :name, :value, :off_value, :form, :sr_label, :data, :class_name

    def initialize(id: nil, checked: false, disabled: false, label: nil, name: nil, value: "1", off_value: "0", form: nil, sr_label: "Toggle", data: {}, class_name: nil)
      @id = id || SecureRandom.uuid
      @checked = checked
      @disabled = disabled
      @label = label
      @name = name
      @value = value
      @off_value = off_value
      @form = form
      @sr_label = sr_label
      @data = data
      @class_name = class_name
    end
  end
end
