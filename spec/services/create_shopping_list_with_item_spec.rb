require 'rails_helper'
RSpec.describe CreateShoppingListWithItem do
  describe '#call' do
    let(:user) { create(:user) }
    it 'creates a shopping list' do
      expect {
        shopping_list = described_class.new(item_name: 'test', owner_id: user.id).call
        expect(shopping_list).to be_a(ShoppingList)
      }.to change(ShoppingList, :count).by(1)
    end

    it ' creates an item on the list' do
      expect {
        described_class.new(item_name: 'test', owner_id: user.id).call
      }.to change(ShoppingListItem, :count).by(1)
    end

    it 'assigns user as owner' do
      shopping_list = described_class.new(item_name: 'test', owner_id: user.id).call
      expect(shopping_list.owner_id).to eq(user.id)
    end

    it 'sets list name to today date' do
      Timecop.freeze(Time.zone.local(2021, 1, 1)) do
        shopping_list = described_class.new(item_name: 'test', owner_id: user.id).call
        expect(shopping_list.name).to eq('2021-01-01')
        end
    end

  end
end