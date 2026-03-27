module Fab
  class ItemComponent < ViewComponent::Base
    def initialize(icon:, path:, label:, confirm_msg: nil, type: nil, method: :get)
      @confirm_msg = confirm_msg
      @icon = icon
      @path = path
      @label = label
      @aria_label = label
      @method = method

      case type
      when :secondary
        @btn_classes = "btn-secondary"
        @label_classes = "bg-secondary text-secondary-content"
      when :success
        @btn_classes = "btn-success"
        @label_classes = "bg-success text-success-content"
      when :error
        @btn_classes = "btn-error"
        @label_classes = "bg-error text-error-content"
      else
        @btn_classes = "btn-primary"
        @label_classes = "bg-primary text-primary-content"
      end
    end
  end
end
