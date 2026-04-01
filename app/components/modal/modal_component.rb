module Modal
  class ModalComponent < ViewComponent::Base
    renders_one :actions
    renders_one :body

    def initialize(title:, closable: true, id: nil)
      @closable = closable
      @id = id || SecureRandom.hex(10)
      @title = title
    end
  end
end
