require 'rails_helper'

RSpec.describe VisitTrackingJob, type: :job do
  let(:user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: create(:user)) }

  describe '#perform' do
    it 'creates a new ListVisit record' do
      expect {
        described_class.perform_now(user_id: user.id, shopping_list_id: shopping_list.id, visited_at: Time.zone.now)
      }.to change { ListVisit.count }.by(1)
    end

    it 'assigns the correct attributes' do
      described_class.perform_now(user_id: user.id, shopping_list_id: shopping_list.id, visited_at: Time.zone.now)

      visit = ListVisit.last
      expect(visit.user).to eq(user)
      expect(visit.shopping_list).to eq(shopping_list)
      expect(visit.visited_at).to be_present
    end

    it 'logs an error if user not found' do
      expect(Rails.logger).to receive(:error)
      described_class.perform_now(user_id: 123, shopping_list_id: shopping_list.id, visited_at: Time.zone.now)
    end

    it 'logs an error if shopping list not found' do
      expect(Rails.logger).to receive(:error)
      described_class.perform_now(user_id: user.id, shopping_list_id: 456, visited_at: Time.zone.now)
    end
  end
end
