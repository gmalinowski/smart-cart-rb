
module Fab
class ContainerComponent < ViewComponent::Base
  renders_many :items, ItemComponent
  def initialize(icon: "plus", type: :secondary)
    @icon = icon
    case type
    when :primary
      @btn_classes = "btn-primary text-primary-content"
    when :success
      @btn_classes = "btn-success text-success-content"
    else
      @btn_classes = "btn-secondary text-secondary-content"
    end
  end
end
end
