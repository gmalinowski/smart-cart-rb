require 'rails_helper'

RSpec.describe InviteFriendService, type: :service do
  context 'invitee is registered' do
    let(:user) { create(:user) }
    let(:invitee) { create(:user) }

    it 'creates a friendship' do
      expect { described_class.new(user: user, invitee_email: invitee.email).call }.to change { Friendship.count }.by(1)
    end

    it 'creates a friendship with status pending' do
      described_class.new(user: user, invitee_email: invitee.email).call
      friendship = Friendship.last
      expect(friendship.status).to eq('pending')
    end
    it 'returns success when friendship is created' do
      response = described_class.new(user: user, invitee_email: invitee.email).call
      expect(response[:success]).to be_truthy
      expect(response[:message]).to eq(:friendship_requested)
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
        expect(response[:message]).to eq(:friendship_requested)
        expect(Friendship.last.friend).to eq(invitee)
      end

      it 'does not create a duplicate if an inverse friendship already exists' do
        create(:friendship, user: invitee, friend: user, status: :pending)

        expect {
          described_class.new(user: user, invitee_email: invitee.email).call
        }.to_not change { Friendship.count }

      end

      it 'does not create a friendship if invitee is the same as user' do
        expect { described_class.new(user: user, invitee_email: user.email).call }.to_not change { Friendship.count }
      end
      it 'does not send a notification to invitee if invitee is the same as user' do
        expect { described_class.new(user: user, invitee_email: user.email).call }.to_not have_enqueued_mail(FriendshipMailer, :invitation_email)
      end
      it 'does not create a friendship if invitee is already friends with user' do
        friendship = create(:friendship, user: user, friend: invitee, status: :accepted)
        expect { described_class.new(user: user, invitee_email: invitee.email).call }.to_not change { Friendship.count }
      end

      it 'raises an error if user is nil' do
        expect { described_class.new(user: nil, invitee_email: invitee.email).call }.to raise_error(ArgumentError)
      end
      it 'raises an error if invitee_email is nil' do
        expect { described_class.new(user: user, invitee_email: nil).call }.to raise_error(ArgumentError)
      end

      it 'does not create a duplicate friendship request' do
        described_class.new(user: user, invitee_email: invitee.email).call
        model_instance = Friendship.new
        error_message = model_instance.errors.generate_message(:friend_id, :pending)
        expect {
          response = described_class.new(user: user, invitee_email: invitee.email).call
          expect(response[:success]).to be_falsey
          expect(response[:errors]).to_not be_nil
        }.not_to change { Friendship.count }
      end
    end

  end

  context 'invitee is not registered' do
    let(:user) { create(:user) }
    let(:invitee_email) { 'unregistered@example.com' }

    it 'does not create a friendship' do
      expect { described_class.new(user: user, invitee_email: invitee_email).call }.to_not change { Friendship.count }
    end

    it 'creates invitation_link' do
      expect { described_class.new(user: user, invitee_email: invitee_email).call }.to change { InvitationLink.count }.by(1)
    end

    it 'creates invitation with type email_invitation' do
      described_class.new(user: user, invitee_email: invitee_email).call
      invitation_link = InvitationLink.last
      expect(invitation_link.invitation_type).to eq('email_invitation')
    end

    it 'creates invitation with recipient_email' do
      described_class.new(user: user, invitee_email: invitee_email).call
      invitation_link = InvitationLink.last
      expect(invitation_link.recipient_email).to eq(invitee_email)
    end

    it 'returns success when invitation is created' do
      response = described_class.new(user: user, invitee_email: invitee_email).call
      expect(response[:success]).to be_truthy
      expect(response[:message]).to eq(:email_invitation_sent)
    end

    it 'sends an email to invitee' do
      ActionMailer::Base.deliveries.clear
      expect {
        described_class.new(user: user, invitee_email: invitee_email).call
      }.to have_enqueued_mail(InvitationMailer, :friend_invitation_to_signup).with(inviter: user, invitee_email: invitee_email)
    end

    describe 'edge cases' do
      it 'raises error when user is nil' do
        expect { described_class.new(user: nil, invitee_email: invitee_email).call }.to raise_error(ArgumentError)
      end

      it 'raises error when invitee_email is nil' do
        expect { described_class.new(user: user, invitee_email: nil).call }.to raise_error(ArgumentError)
      end

      it 'does not create an invitation if invitee_email is empty' do
        response = described_class.new(user: user, invitee_email: '').call
        expect(InvitationLink.count).to eq(0)
        expect(response[:success]).to be_falsey
        expect(response[:errors]).not_to be_nil
      end

      it 'does not create an invitation if invitee_email is invalid' do
        expect { described_class.new(user: user, invitee_email: 'invalid_email').call }.not_to change { InvitationLink.count }
      end

      it 'does not create an invitation if already has an active invitation for the same email' do
        create(:invitation_link, user: user, recipient_email: invitee_email, invitation_type: :email_invitation)
        response = described_class.new(user: user, invitee_email: invitee_email).call

        il = InvitationLink.new
        il.errors.add(:recipient_email, :taken)
        expected_error = il.errors.full_messages

        expect(InvitationLink.count).to eq(1)
        expect(response[:success]).to be_falsey
        expect(response[:errors]).to eq(expected_error)
      end

      it 'create a new invitation if existing one has other type' do
        create(:invitation_link, user: user)
        expect {
          described_class.new(user: user, invitee_email: invitee_email).call
        }.to change { InvitationLink.count }.by(1)
      end
      it 'creates a new invitation if the same email was invited by a different user' do
        other_user = create(:user)
        create(:invitation_link, user: other_user, recipient_email: invitee_email, invitation_type: :email_invitation)

        service = described_class.new(user: user, invitee_email: invitee_email)

        expect { service.call }.to change { user.invitation_links.count }.by(1)

        expect(InvitationLink.active_for_recipient_email(invitee_email).count).to eq(2)
        expect(user.invitation_links.active_for_recipient_email(invitee_email).count).to eq(1)
        expect(other_user.invitation_links.active_for_recipient_email(invitee_email).count).to eq(1)
      end

      it 'reactivate old invitation if existing one has expired' do
        create(:invitation_link, user: user, recipient_email: invitee_email, expires_at: 1.day.ago, invitation_type: :email_invitation)

        expect(InvitationLink.active_for_recipient_email(invitee_email).count).to eq(0)
        service = described_class.new(user: user, invitee_email: invitee_email)

        expect { service.call }.to change { InvitationLink.count }.by(0)

        expect(InvitationLink.active_for_recipient_email(invitee_email).count).to eq(1)
      end
    end
  end
end