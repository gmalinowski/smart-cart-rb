require 'rails_helper'

RSpec.describe GroupShoppingList, type: :model do
  subject { build(:group_shopping_list, group: create(:group), shopping_list: create(:shopping_list)) }
  it { should belong_to(:group) }
  it { should belong_to(:shopping_list) }
  it { should validate_uniqueness_of(:shopping_list_id).scoped_to(:group_id).ignoring_case_sensitivity }
  it { should validate_presence_of(:group_id) }
  it { should validate_presence_of(:shopping_list_id) }
end
