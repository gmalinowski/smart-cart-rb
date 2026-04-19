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

  describe 'validations' do
    it { should validate_presence_of(:email) }

    it 'does not allow to be friends with oneself' do
      user = create(:user)
      friendship = build(:friendship, user: user, friend: user)
      expect(friendship).not_to be_valid
      expect(friendship.errors[:friend]).to be_present
    end

    it 'does not allow a friendship to exist if one already exists in the opposite direction' do
      user_a = create(:user)
      user_b = create(:user)
      create(:friendship, user: user_a, friend: user_b)

      reverse_friendship = build(:friendship, user: user_b, friend: user_a)
      expect(reverse_friendship).not_to be_valid
    end

    it 'does not allow duplicate friendship records' do
      user_a = create(:user)
      user_b = create(:user)
      create(:friendship, user: user_a, friend: user_b)

      duplicate = build(:friendship, user: user_a, friend: user_b)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'email_invitations' do
    let(:user) { create(:user) }
    let(:user_2) { create(:user) }
    let(:friend_email) { "friend_xyz@example.com" }
    context 'when user signs up' do
      context 'when user confirms email or create confirmed account' do
        it 'should claim one pending invitation on confirm' do
          create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)
          friend = create(:user, email: friend_email, confirmed_at: nil)

          expect {
            friend.confirm
          }.to change { Friendship.count }.by(1)
        end

        it 'should claim one pending invitation on create confirmed account' do
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
          }.to_not change { InvitationLink.count }
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
    end
    context 'transactional integrity' do
      it 'does not increment uses_count if friendship creation fails' do
        invitation_link = create(:invitation_link, user: user, recipient_email: friend_email)

        allow(Friendship).to receive(:create).and_raise(ActiveRecord::Rollback)

        expect {
          begin
            create(:user, email: friend_email)
          rescue
            nil
          end
          invitation_link.reload
        }.not_to change { invitation_link.uses_count }
      end
    end

    context 'when friend does not confirm email' do
      it 'should not claim invitation' do
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend_email)
        expect {
          create(:user, email: friend_email, confirmed_at: nil)
        }.to_not change { Friendship.count }
      end
    end

    context 'when friend has account but not confirmed email' do
      it 'creates email_invitation' do
        friend = create(:user, email: friend_email, confirmed_at: nil)
        expect {
          create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: friend.email)
        }.to change { InvitationLink.count }
      end
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
    let!(:user) { create(:user) }
    it 'destroys associated shopping_lists when destroyed'

    it 'destroys sent and received friendships when destroyed' do
      create(:friendship, user: user, friend: create(:user))
      create(:friendship, user: create(:user), friend: user)

      expect { user.destroy }.to change { Friendship.count }.by(-2)
    end
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

      it 'returns false if friendship is declined' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend, status: :rejected)
        expect(user.friends_with?(friend)).to be_falsey
        expect(user.pending_friendship_with?(friend)).to be_falsey
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

    it { should have_many(:user_friend_views).with_foreign_key('user_id') }
    it { should have_many(:friends).through(:user_friend_views).source(:friend) }
    it { should have_many(:pending_friends).through(:user_friend_views).source(:friend).conditions(friendships: { status: :pending }) }
    it { should have_many(:pending_received_friends).through(:user_friend_views).source(:friend).conditions(friendships: { status: :pending }) }
    it { should have_many(:pending_sent_friends).through(:user_friend_views).source(:friend).conditions(friendships: { status: :pending }) }

    it { should have_many(:sent_friendships).with_foreign_key('user_id').dependent(:destroy) }
    it { should have_many(:received_friendships).with_foreign_key('friend_id').dependent(:destroy) }
    it { should have_many(:pending_sent_friendships).with_foreign_key('user_id').conditions(status: :pending).dependent(:destroy) }
    it { should have_many(:pending_received_friendships).with_foreign_key('friend_id').conditions(status: :pending).dependent(:destroy) }

    it { should have_many(:list_visits).dependent(:destroy) }
    it { should have_one(:last_list_visit).order(visited_at: :desc).class_name('ListVisit') }
    it { should have_one(:last_visited_shopping_list).through(:last_list_visit).source(:shopping_list) }

    it { should have_many(:invitation_links) }

    describe '#last_visited_shopping_list' do
      let(:user) { create(:user) }
      let(:shopping_list) { create(:shopping_list, owner: user) }
      let(:shopping_list_2) { create(:shopping_list, owner: create(:user)) }

      it 'returns the most recently visited shopping list if only one visited' do
        create(:list_visit, user: user, shopping_list: shopping_list)
        expect(user.last_visited_shopping_list).to eq(shopping_list)
      end

      it 'returns the most recently visited shopping list if many visited' do
        create(:list_visit, user: user, shopping_list: shopping_list)
        create(:list_visit, user: user, shopping_list: shopping_list_2)
        expect(user.last_visited_shopping_list).to eq(shopping_list_2)
      end

      it 'returns nil if no shopping lists have been visited' do
        expect(user.last_visited_shopping_list).to be_nil
      end

    end

    describe '#friends' do
      let(:user) { create(:user) }
      let(:friend_accepted) { create(:user) }
      let(:friend_pending) { create(:user) }
      let(:friend_2) { create(:user) }

      before do
        create(:friendship, user: user, friend: friend_accepted, status: :accepted)
        create(:friendship, user: user, friend: friend_pending, status: :pending)
        create(:friendship, user: friend_2, friend: user, status: :pending)
      end

      it 'returns all pending friends regardless of who is sender' do
        expect(user.pending_friends).to include(friend_pending)
        expect(user.pending_friends).to include(friend_2)
      end

      it 'returns only pending friends where user is the sender' do
        expect(user.pending_sent_friends).to include(friend_pending)
        expect(user.pending_sent_friends).not_to include(friend_accepted)
        expect(user.pending_sent_friends).not_to include(friend_2)
      end

      it 'returns only pending friends where user is the recipient' do
        expect(user.pending_received_friends).to include(friend_2)
        expect(user.pending_received_friends).not_to include(friend_accepted)
        expect(user.pending_received_friends).not_to include(friend_pending)
      end

      it 'does not include accepted friends in pending lists' do
        accepted_friend = create(:user)
        create(:friendship, user: user, friend: accepted_friend, status: :accepted)

        expect(user.pending_friends).not_to include(accepted_friend)
      end

      it 'returns accepted friends' do
        expect(user.friends).to include(friend_accepted)
        expect(user.friends).not_to include(friend_pending)
      end

      it 'returns pending friends' do
        expect(user.pending_friends).to include(friend_pending)
        expect(user.pending_friends).not_to include(friend_accepted)
      end
    end
  end
end
