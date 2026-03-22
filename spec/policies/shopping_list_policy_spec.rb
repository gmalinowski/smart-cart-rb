
require 'rails_helper'

RSpec.describe ShoppingListPolicy, type: :policy do
  subject { described_class.new(user, shopping_list) }

  let(:owner) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }

  context 'owner' do
    let(:user) { owner }
  end
end
