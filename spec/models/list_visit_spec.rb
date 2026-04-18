require 'rails_helper'

RSpec.describe ListVisit, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:shopping_list) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:shopping_list_id) }
  end
end