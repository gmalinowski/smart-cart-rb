require 'rails_helper'

RSpec.describe "Friends", type: :request do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  describe "GET /friends" do
    context 'when user is logged in' do
      before { sign_in_with_session user }

      it "returns http success" do
        get friends_path
        expect(response).to have_http_status(:success)
      end

      it "assigns @friends" do
        create(:friendship, user: user, friend: friend, status: :accepted)
        create(:friendship, user: user, friend: create(:user), status: :accepted)
        create(:friendship, user: user, friend: create(:user), status: :pending)
        get friends_path
        expect(assigns(:friends)).to eq(user.friends)
        expect(assigns(:friends).size).to eq(2)
      end

      it "assigns @pending_received_friendships" do
        create(:friendship, user: user, friend: friend, status: :pending)
        create(:friendship, user: user, friend: create(:user), status: :accepted)
        create(:friendship, user: create(:user), friend: user, status: :pending)
        create(:friendship, user: create(:user), friend: user, status: :pending)
        get friends_path
        expect(assigns(:pending_received_friendships)).to eq(user.pending_received_friendships)
        expect(assigns(:pending_received_friendships).size).to eq(2)
      end

      it "assigns @pending_friendships" do
        create(:friendship, user: friend, friend: user, status: :pending)
        create(:friendship, user: create(:user), friend: user, status: :accepted)
        create(:friendship, user: user, friend: create(:user), status: :pending)
        create(:friendship, user: user, friend: create(:user), status: :pending)
        get friends_path
        expect(assigns(:pending_friendships)).to eq(user.pending_friendships)
        expect(assigns(:pending_friendships).size).to eq(2)
      end
    end
    context 'when user is not logged in' do
      it "redirects to sign in page" do
        get friends_path
        expect(response).to redirect_to(new_user_session_path)
        end
      end
  end
end
