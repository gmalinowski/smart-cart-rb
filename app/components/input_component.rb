# frozen_string_literal: true

class InputComponent < ViewComponent::Base
  include RailsHeroicon::Helper
  def initialize(label:, icon:, **options)
    @label = label
    @icon = icon
    @options = options
  end
end
