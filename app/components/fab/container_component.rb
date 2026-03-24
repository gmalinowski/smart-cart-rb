
module Fab
class ContainerComponent < ViewComponent::Base
  renders_many :items, ItemComponent
  def initialize(icon: "plus")
    @icon = icon
  end
end
end
