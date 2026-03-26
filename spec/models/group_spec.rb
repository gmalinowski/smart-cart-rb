require 'rails_helper'

RSpec.describe Group, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:owner_id) }
  it { should belong_to(:owner).class_name('User') }
  it { should have_many(:shopping_lists).through(:group_shopping_lists) }

  it "destroy associated group_shopping_lists when destroyed" do
    group = create(:group)
    group.group_shopping_lists.create!(shopping_list: create(:shopping_list))
    expect { group.destroy }.to change(GroupShoppingList, :count).by(-1)
  end

  it "should have many shopping lists"
end
