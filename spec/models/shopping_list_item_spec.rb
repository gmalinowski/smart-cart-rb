require 'rails_helper'

RSpec.describe ShoppingListItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:shopping_list) }
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
  end
end
