require 'rails_helper'

RSpec.describe InviteFriendService, type: :service do
  context 'invitee is registered' do
    let(:user) { create(:user) }
    let(:invitee) { create(:user) }

    it 'creates a friendship' do
      expect{ described_class.new(user: user, invitee_email: invitee.email).call }.to change{ Friendship.count }.by(1)
    end

    it 'creates a friendship with status pending' do
      described_class.new(user: user, invitee_email: invitee.email).call
      friendship = Friendship.last
      expect(friendship.status).to eq('pending')
    end
    it 'returns success when friendship is created' do
      response = described_class.new(user: user, invitee_email: invitee.email).call
      expect(response[:success]).to be_truthy
      expect(response[:message]).to eq(:success)
    end
    it 'returns error when friendship cannot be created' do
      allow_any_instance_of(Friendship).to receive(:save).and_return(false)
      response = described_class.new(user: user, invitee_email: invitee.email).call
      expect(response[:success]).to be_falsey
      expect(response[:errors]).not_to be_nil
    end
    it 'sends a notification to invitee via email' do
      ActionMailer::Base.deliveries.clear
      expect {
        described_class.new(user: user, invitee_email: invitee.email).call
      }.to have_enqueued_mail(FriendshipMailer, :invitation_email).with(inviter: user, invitee_email: invitee.email)
    end

    describe 'edge cases' do

      it 'finds existing user even with uppercase and spaces in email' do
        invitee = create(:user, email: 'serwis@test.pl')
        response = described_class.new(user: user, invitee_email: ' SERWIS@test.pl ').call

        expect(response[:success]).to be_truthy
        expect(response[:message]).to eq(:success)
        expect(Friendship.last.friend).to eq(invitee)
      end

      it 'does not create a duplicate if an inverse friendship already exists' do
        create(:friendship, user: invitee, friend: user, status: :pending)

        expect {
          described_class.new(user: user, invitee_email: invitee.email).call
        }.to_not change { Friendship.count }

      end

      it 'does not create a friendship if invitee is the same as user' do
        expect{ described_class.new(user: user, invitee_email: user.email).call }.to_not change{ Friendship.count }
      end
      it 'does not send a notification to invitee if invitee is the same as user' do
        expect{ described_class.new(user: user, invitee_email: user.email).call }.to_not have_enqueued_mail(FriendshipMailer, :invitation_email)
      end
      it 'does not create a friendship if invitee is already friends with user' do
        friendship = create(:friendship, user: user, friend: invitee, status: :accepted)
        expect{ described_class.new(user: user, invitee_email: invitee.email).call }.to_not change{ Friendship.count }
      end

      it 'raises an error if user is nil' do
        expect{ described_class.new(user: nil, invitee_email: invitee.email).call }.to raise_error(ArgumentError)
      end
      it 'raises an error if invitee_email is nil' do
        expect{ described_class.new(user: user, invitee_email: nil).call }.to raise_error(ArgumentError)
      end
    end

  end

  context 'invitee is not registered' do

  end
end