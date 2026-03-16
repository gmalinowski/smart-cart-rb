# frozen_string_literal: true

class ExampleComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
    @title_size = "text-2xl"
  end
end
