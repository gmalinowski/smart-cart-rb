require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'session_version' do
    it 'should be incremented when password is changed' do
      user = create(:user)
      expect {
        user.update(password: 'P@assword12', password_confirmation: 'P@assword12')
      }.to change { user.session_version }.by(1)
    end

    it 'does not increment when other attributes change' do
      user = create(:user)
      expect {
        user.update(email: '1234@ggg.com')
      }.not_to change { user.session_version }
    end
  end

  describe 'email_invitations' do
    context 'when user signs up' do
      let(:user) { create(:user) }
      let(:user_2) { create(:user) }
      let(:friend_email) { "friend_xyz@example.com" }

      it 'should claim one pending invitation' do
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)

        expect {
          create(:user, email: friend_email)
        }.to change { Friendship.count }.by(1)
      end

      it 'should claim many pending invitations' do
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)
        create(:invitation_link, user: user_2, invitation_type: :email_invitation, recipient_email: friend_email)
        expect {
          create(:user, email: friend_email)
        }.to change { Friendship.count }.by(2)
      end

      it 'should disappear after claiming' do
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)
          friend = create(:user, email: friend_email)
        expect(friend.invitation_links.count).to eq(0)
      end

      it 'should not claim invitation if it is expired' do
        invitation_link = create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email, expires_at: 1.day.ago)
        expect {
          create(:user, email: friend_email)
        }.to_not change { user.pending_invitations_received.count }
      end

      it 'should not change number of all invitations' do
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)
        expect {
          create(:user, email: friend_email)
        }.to_not change { user.invitation_links.count }
      end

      it 'should decrease number of active invitations' do
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)
        expect {
          create(:user, email: friend_email)
        }.to change { InvitationLink.active.count }.by(-1)
      end

      it 'should create new friendships with status pending' do
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)
        create(:invitation_link, user: user_2, invitation_type: :email_invitation, recipient_email: friend_email)
        friend = create(:user, email: friend_email)
        friend.reload
        expect(friend.pending_received_friendships.count).to eq(2)
      end
    end

    describe 'helper' do
      describe '#pending_invitations_received' do

        it 'returns all invitations for this user identified by email' do
          user = create(:user)
          friend = create(:user)

          create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend.email)

          expect(friend.pending_invitations_received.count).to eq(1)
          expect(friend.pending_invitations_received).to all(be_a(InvitationLink))
        end

        it 'returns invitations regardless of email case sensitivity' do
          user = create(:user)
          friend = create(:user, email: 'MAMA@example.com')

          create(:invitation_link,
                 user: user,
                 invitation_type: :email_invitation,
                 recipient_email: 'mama@example.com')

          expect(friend.pending_invitations_received.count).to eq(1)
        end

        it 'does not return invitations that are already claimed or expired' do
          user = create(:user)
          user_2 = create(:user)
          friend = create(:user)

          # Zaproszenie wygasłe
          create(:invitation_link,
                 user: user,
                 expires_at: 1.day.ago,
                 invitation_type: :email_invitation,
                 recipient_email: friend.email)

          # Zaproszenie już wykorzystane (uses_count >= max_uses)
          create(:invitation_link,
                 user: user_2,
                 invitation_type: :email_invitation,
                 recipient_email: friend.email,
                 uses_count: 1,
                 max_uses: 1)

          expect(friend.pending_invitations_received.count).to eq(0)
        end

        it 'does not return invitations with different invitation type' do
          user = create(:user)
          friend = create(:user)
          create(:invitation_link, user: user, invitation_type: :link_invitation, recipient_email: friend.email)
          expect(friend.pending_invitations_received.count).to eq(0)
        end

        it 'does not return invitations for other users' do
          user = create(:user)
          friend = create(:user)
          friend_2 = create(:user)

          invitation = create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend.email)
          create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_2.email)

          expect(friend.pending_invitations_received.count).to eq(1)
          expect(friend.pending_invitations_received).to eq([invitation])
        end
      end

      # describe '#pending_invitations_sent' do
      #
      #   it 'returns invitations created by this user that are not yet claimed' do
      #     user = create(:user)
      #     friend = create(:user)
      #
      #     create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend.email)
      #
      #     expect(user.sent_pending_email_invitations.count).to eq(1)
      #   end
      # end
    end

  end

  describe 'email' do
    it 'downcase and stripe' do
      user = create(:user, email: " JAN@EXAMPLE.COM    ")

      expect(user.email).to eq("jan@example.com")
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
  end

  describe 'dependencies' do
    it 'destroys associated shopping_lists when destroyed'
  end

  describe 'helpers' do
    describe 'friends_with?' do
      it 'returns true if user is friends with friend' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend, status: :accepted)
        expect(user.friends_with?(friend)).to be_truthy
      end
      it 'returns false if user is not friends with friend' do
        user = create(:user)
        friend = create(:user)
        expect(user.friends_with?(friend)).to be_falsey
      end
      it 'returns false if friend is nil' do
        user = create(:user)
        expect(user.friends_with?(nil)).to be_falsey
      end
      it 'returns false if user is nil' do
        friend = create(:user)
        expect(User.new.friends_with?(friend)).to be_falsey
      end
      it 'returns false if friendship is not accepted' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend)
        expect(user.friends_with?(friend)).to be_falsey
      end
    end

    describe 'pending_friends_with?' do
      it 'returns true if user is pending friend with friend' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend, status: :pending)
        expect(user.pending_friendship_with?(friend)).to be_truthy
      end
      it 'returns false if user is not friend with friend' do
        user = create(:user)
        friend = create(:user)
        expect(user.pending_friendship_with?(friend)).to be_falsey
      end
      it 'returns false if friend is nil' do
        user = create(:user)
        expect(user.pending_friendship_with?(nil)).to be_falsey
      end
      it 'returns false if user is nil' do
        friend = create(:user)
        expect(User.new.pending_friendship_with?(friend)).to be_falsey
      end
      it 'returns false if users are accepted friends' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend, status: :accepted)
        expect(user.pending_friendship_with?(friend)).to be_falsey
      end
    end
  end

  describe 'associations' do
    it { should have_many(:shopping_lists).with_foreign_key('owner_id') }
    it { should have_many(:groups).with_foreign_key('owner_id') }

    it { should have_many(:friendships) }
    it { should have_many(:friends).through(:user_friend_views) }
    it { should have_many(:pending_friendships).with_foreign_key('user_id').class_name('Friendship').conditions(status: :pending) }
    it { should have_many(:pending_received_friendships).with_foreign_key('friend_id').class_name('Friendship').conditions(status: :pending) }

    it { should have_many(:invitation_links) }
  end
end
