require 'rails_helper'

RSpec.describe Visits::Track, type: :service do
  let(:user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }

  describe '.call' do
    context 'when visiting for the first time' do
      it 'creates a new ListVisit record' do
        expect {
          described_class.call(user: user, shopping_list: shopping_list)
        }.to change { ListVisit.count }.by(1)
      end

      it 'sets the initial interaction_count to 1' do
        described_class.call(user: user, shopping_list: shopping_list)
        visit = ListVisit.last
        expect(visit.interaction_count).to eq(1)
      end

      it 'sets the visited_at timestamp' do
        travel_to Time.zone.local(2021, 1, 1) do
          described_class.call(user: user, shopping_list: shopping_list)
          visit = ListVisit.last
          expect(visit.visited_at).to eq(Time.zone.local(2021, 1, 1))
        end
      end
    end
    context 'when visiting again after 1h+' do
      let!(:visit) { create(:list_visit, user: user, shopping_list: shopping_list, interaction_count: 1, visited_at: 2.hours.ago) }
      it 'updates the existing ListVisit record instead of creating a new one' do
        expect {
          described_class.call(user: user, shopping_list: shopping_list)
        }.not_to change { ListVisit.count }
      end

      it 'updates the visited_at timestamp' do
        described_class.call(user: user, shopping_list: shopping_list)
        visit = ListVisit.last
        expect(visit.visited_at).to be_within(1.minute).of(Time.zone.now)
      end

      it 'increments the interaction_count' do
        expect {
          described_class.call(user: user, shopping_list: shopping_list)
        }.to change { visit.reload.interaction_count }.by(1)
      end
    end

    context 'debounce logic within 1h' do
      let!(:recent_visit) { create(:list_visit, user: user, shopping_list: shopping_list, interaction_count: 1, visited_at: 50.minutes.ago) }

      it 'does not increment the interaction_count if the last visit was less than 1 hour ago' do
        expect {
          described_class.call(user: user, shopping_list: shopping_list)
        }.to change { recent_visit.reload.interaction_count }.by(0)
      end

      it 'updates the visited_at timestamp' do
        expect {
          described_class.call(user: user, shopping_list: shopping_list)
        }.to change { recent_visit.reload.visited_at }
      end
    end

    describe 'validations' do
      it 'raises an error if user is nil' do
        expect { described_class.call(user: nil, shopping_list: shopping_list) }.to raise_error(ArgumentError)
      end

      it 'raises an error if shopping_list is nil' do
        expect { described_class.call(user: user, shopping_list: nil) }.to raise_error(ArgumentError)
      end
    end
  end
end
