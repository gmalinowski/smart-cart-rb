
module Fab
class ContainerComponent < ViewComponent::Base
  renders_many :items, ItemComponent
end
end
