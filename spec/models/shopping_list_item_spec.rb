require 'rails_helper'

RSpec.describe ShoppingListItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end



  describe 'associations' do
    it { should belong_to(:shopping_list) }
  end
end
