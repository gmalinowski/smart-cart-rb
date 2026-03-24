
module Fab
  class ItemComponent < ViewComponent::Base
    def initialize(icon:, path:, label:, method: :get)
      @icon = icon
      @path = path
      @label = label
      @aria_label = label
      @method = method
    end
  end
end
