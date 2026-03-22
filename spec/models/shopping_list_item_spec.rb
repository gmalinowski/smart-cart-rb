require 'rails_helper'

RSpec.describe ShoppingListItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:shopping_list) }
  end

  describe 'scopes' do
    let(:list) { create(:shopping_list) }
    it '.unchecked_first' do
      c1 = list.shopping_list_items.create!(name: 'test', checked: true)
      uc1 = list.shopping_list_items.create!(name: 'test2', checked: false)
      c2 = list.shopping_list_items.create!(name: 'test', checked: true)
      uc2 = list.shopping_list_items.create!(name: 'test2', checked: false)
      expect(list.shopping_list_items.unchecked_first).to eq([ uc1, uc2, c1, c2 ])
    end
  end

  describe 'broadcasts' do
    let(:list) { create(:shopping_list) }
    it 'broadcasts append after create' do
      expect {
        create(:shopping_list_item, shopping_list: list)
      }.to have_broadcasted_to(list.to_gid_param).with(a_string_including("prepend"))
    end

    it 'broadcasts remove after destroy' do
      item = create(:shopping_list_item, shopping_list: list)
      expect {
        item.destroy
      }.to have_broadcasted_to(list.to_gid_param).with(a_string_including("remove"))
    end

    it 'broadcasts replace after toggle' do
      item = create(:shopping_list_item, shopping_list: list)
      expect {
        item.update!(checked: true)
      }.to have_broadcasted_to(list.to_gid_param).with(a_string_including("replace"))
    end
  end
end
