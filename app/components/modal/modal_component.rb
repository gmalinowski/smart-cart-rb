module Modal
class ModalComponent < ViewComponent::Base
  renders_one :actions
  renders_one :body
  def initialize(id:, title:)
    @id = id
    @title = title
  end
end
end