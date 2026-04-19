require 'rails_helper'

RSpec.describe ListVisit, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:shopping_list) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:shopping_list_id) }
    it { should validate_presence_of(:interaction_count) }
    it { should validate_presence_of(:visited_at) }

    describe 'uniqueness of user_id scoped to shopping_list_id' do
      subject { create(:list_visit, user: create(:user), shopping_list: create(:shopping_list)) }
      it { should validate_uniqueness_of(:user_id).scoped_to(:shopping_list_id).ignoring_case_sensitivity }
    end
  end
end
