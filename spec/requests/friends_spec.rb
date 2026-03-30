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
        get friends_path
        expect(assigns(:friends)).to eq(user.friends)
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