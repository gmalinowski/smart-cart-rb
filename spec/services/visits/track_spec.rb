require 'rails_helper'

RSpec.describe Visits::Track, type: :service do
  let(:user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }

  describe '.call' do

    it 'enqueues a job to track the visit with correct parameters' do
      travel_to Time.zone.local(2023, 1, 1, 12, 0, 0) do
        expect {
          Visits::Track.call(user: user, shopping_list: shopping_list)
        }.to have_enqueued_job(VisitTrackingJob).with(user_id: user.id, shopping_list_id: shopping_list.id, visited_at: Time.zone.now)
      end
    end

    it 'raises an error if user is missing' do
      expect {
        Visits::Track.call(user: nil, shopping_list: shopping_list)
      }.to raise_error(ArgumentError)
    end

    it 'raises an error if shopping list is missing' do
      expect {
        Visits::Track.call(user: user, shopping_list: nil)
      }.to raise_error(ArgumentError)
    end

    describe 'debounce' do
      let(:other_list) { create(:shopping_list, owner: user) }
      it 'does not enqueue a job if the last visited list is the same as the one currently visited' do
        create(:list_visit, user: user, shopping_list: shopping_list, visited_at: Time.zone.now - 5.hour)
        expect {
          Visits::Track.call(user: user, shopping_list: shopping_list)
        }.not_to have_enqueued_job(VisitTrackingJob)
      end
    end
  end
end