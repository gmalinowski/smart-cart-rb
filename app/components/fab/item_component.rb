
module Fab
  class ItemComponent < ViewComponent::Base
    def initialize(icon:, path:, label:, btn_type: :success, method: :get)
      @btn_type = btn_type
      @icon = icon
      @path = path
      @label = label
      @aria_label = label
      @method = method
    end
  end
end
