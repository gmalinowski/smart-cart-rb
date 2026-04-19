require 'rails_helper'

RSpec.describe ShoppingLists::RecentlyVisited, type: :query do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:list) { create(:shopping_list, owner: user) }
  let!(:list_2) { create(:shopping_list, owner: other_user) }
  let!(:list_3) { create(:shopping_list, owner: other_user) }

  it "returns only lists visited by the specific user" do
    create(:list_visit, user: user, shopping_list: list)
    create(:list_visit, user: other_user, shopping_list: list_2)
    expect(described_class.new(user, scope: ShoppingList.all).call).to eq([list])
  end

  it 'raises error when scope is not provided' do
    expect { described_class.new(user).call }.to raise_error(ArgumentError)
  end

  it "returns lists in descending order of visit date" do
    create(:list_visit, user: user, shopping_list: list, visited_at: 1.day.ago)
    create(:list_visit, user: user, shopping_list: list_2, visited_at: 1.hour.ago)
    create(:list_visit, user: user, shopping_list: list_3, visited_at: 2.days.ago)
    expect(described_class.new(user, scope: ShoppingList.all).call).to eq([list_2, list, list_3])
  end

  it "respects the provided scope" do
    create(:list_visit, user: other_user, shopping_list: list_2, visited_at: 1.day.ago)
    create(:list_visit, user: other_user, shopping_list: list_3, visited_at: 2.days.ago)
    create(:list_visit, user: other_user, shopping_list: list, visited_at: 1.hour.ago)
    create(:list_visit, user: user, shopping_list: list, visited_at: 1.day.ago)

    restricted_scope = ShoppingList.where.not(id: list.id)

    result = described_class.new(other_user, scope: restricted_scope).call
    expect(restricted_scope.count).to eq(2)
    expect(ShoppingList.count).to eq(3)
    expect(result).to eq([list_2, list_3])
  end

end