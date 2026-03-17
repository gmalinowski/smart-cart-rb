require 'rails_helper'

RSpec.describe ShoppingList, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner_id) }
  end

  describe 'associations' do
    it { should have_many(:shopping_list_items) }
    it 'destroys associated shopping_list_items' do
      list = create(:shopping_list)
      list.shopping_list_items.create!(name: 'test')
      expect { list.destroy }.to change(ShoppingListItem, :count).by(-1)
    end
  end
end
