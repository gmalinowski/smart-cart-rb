require 'rails_helper'

RSpec.describe ShoppingList, type: :model do
  let(:shopping_list) { create(:shopping_list) }

  let(:list_with_public_links) do
    list = create(:shopping_list)
    create(:shopping_list_public_link, shopping_list: list, created_by: create(:user))
    list
  end

  let(:list_with_items) do
    list = create(:shopping_list)
    list.shopping_list_items.create!(name: 'test')
    list.shopping_list_items.create!(name: 'test')
    list
  end

  describe 'relationships' do
    it { should belong_to(:owner) }
    it { should have_many(:shopping_list_public_links) }
    it { should have_many(:groups).through(:group_shopping_lists) }
  end

  describe 'dependencies' do
    it 'destroys associated shopping_list_public_links when destroyed' do
      list = list_with_public_links
      expect { list.destroy }.to change(ShoppingListPublicLink, :count).by(-1)
    end

    it 'destroys associated shopping_list_items when destroyed' do
      list = list_with_items
      expect { list.destroy }.to change(ShoppingListItem, :count).by(-2)
    end

    it 'destroys associated group_shopping_lists when destroyed' do
      list = list_with_items
      list.groups << create(:group)
      expect { list.destroy }.to change(GroupShoppingList, :count).by(-1)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner_id) }
  end

  describe 'scopes' do
    let(:list) { create(:shopping_list) }
    it 'returns only public lists'
  end

  describe 'associations' do
    it { should have_many(:shopping_list_items) }
    it 'destroys associated shopping_list_items' do
      list = create(:shopping_list)
      list.shopping_list_items.create!(name: 'test')
      expect { list.destroy }.to change(ShoppingListItem, :count).by(-1)
    end
  end

  describe 'helpers' do
    it 'adds item to shopping list' do
      list = create(:shopping_list)
      expect {
        list.add_item!('test')
      }.to change(list.shopping_list_items, :count).by(1)
    end

    it 'removes item from shopping list' do
      list = create(:shopping_list)
      item = list.shopping_list_items.create!(name: 'test')
      expect {
        list.destroy_item(item)
      }.to change(list.shopping_list_items, :count).by(-1)
    end
  end

  describe '.drafts' do
    it 'returns only drafts' do
      user = create(:user)
      ShoppingLists::CreateWithItem.new(item_name: 'test', owner_id: user.id).call
      ShoppingLists::CreateWithItem.new(item_name: 'test', owner_id: user.id).call
      expect(ShoppingList.drafts.count).to eq(2)
    end

    it 'excludes lists that belongs to groups'
    it 'excludes shared with other users lists'
    it 'excludes public lists'
  end
end
