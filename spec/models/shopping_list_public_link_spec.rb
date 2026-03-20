
require 'rails_helper'

RSpec.describe ShoppingListPublicLink, type: :model do
  describe 'relationships' do
    it { should belong_to(:shopping_list) }
    it { should belong_to(:created_by) }
  end
end
