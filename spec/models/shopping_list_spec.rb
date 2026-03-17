require 'rails_helper'

RSpec.describe ShoppingList, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner_id) }
  end
end
