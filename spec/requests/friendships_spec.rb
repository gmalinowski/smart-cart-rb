require 'rails_helper'

RSpec.describe "Friendships", type: :request do

  describe "DELETE /friendships/:id" do
    let(:user) { create(:user) }
    let(:friend) { create(:user) }
    let!(:friendship) { create(:friendship, user: friend, friend: user, status: :accepted) }
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "deletes friendship" do
        expect {
          delete friendship_path(friendship)
        }.to change(Friendship, :count).by(-1)
      end

      it "redirects to friends page" do
        delete friendship_path(friendship)
        expect(response).to redirect_to(friends_path)
      end

      it "shows flash message when status is accepted" do
        delete friendship_path(friendship)
        expect(flash[:warning]).to eq(I18n.t("friendships.destroy.success"))
      end

      it "shows flash message when status is pending" do
        friendship.update(status: :pending)
        delete friendship_path(friendship)
        expect(flash[:warning]).to eq(I18n.t("friendships.destroy.request.success"))
      end

      it "returns 404 if friendship not found" do
        delete friendship_path("non-existent-id")
        expect(response).to have_http_status(:redirect)
      end

      it "show flash message and redirects if friendship not found" do
        delete friendship_path("non-existent-id")
        expect(flash[:alert]).to eq(I18n.t("errors.messages.not_found"))
        expect(response).to have_http_status(:redirect)
      end

      it "show flash message if cannot delete friendship" do
        allow_any_instance_of(Friendship).to receive(:destroy).and_return(false)
        delete friendship_path(friendship)
        expect(flash[:alert]).to eq(I18n.t("friendships.destroy.error"))
        expect(Friendship.count).to eq(1)
        expect(response).to redirect_to(friends_path)
      end
    end
    context 'when user is not logged in' do
      it "redirects to sign in page" do
        expect {
          delete friendship_path(friendship)
        }.not_to change(Friendship, :count)
        expect(response).to have_http_status(:found) # 302 redirect
      end
    end
  end

  describe "PATCH /friendships/:id/confirm" do
    let(:user) { create(:user) }
    let(:friend) { create(:user) }
    let(:friendship) { create(:friendship, user: friend, friend: user, status: :pending) }

    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "updates friendship status to accepted" do
        patch confirm_friendship_path(friendship)
        friendship.reload
        expect(friendship.status).to eq("accepted")
      end
      it "redirects after confirming" do
        patch confirm_friendship_path(friendship)
        expect(response).to redirect_to(friends_path)
      end

      it "show flash message after confirming" do
        patch confirm_friendship_path(friendship)
        expect(flash[:success]).to eq(I18n.t("friendships.confirm.success"))
      end

      it "cannot confirm friendship if not the invitee" do
        other_friendship = create(:friendship, user: user, friend: friend, status: :pending)
        patch confirm_friendship_path(other_friendship)
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
        expect(other_friendship.reload.status).to eq("pending")
      end

      it "cannot confirm already accepted friendship" do
        accepted = create(:friendship, user: friend, friend: user, status: :accepted)
        patch confirm_friendship_path(accepted)
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
        expect(accepted.reload.status).to eq("accepted")
      end

      it "cannot confirm friendship of stranger" do
        stranger = create(:user)
        other = create(:friendship, user: stranger, friend: friend, status: :pending)
        patch confirm_friendship_path(other)
        expect(response).to have_http_status(:forbidden).or redirect_to(root_path)
        expect(other.reload.status).to eq("pending")
      end

      it "show flash msg and redirects if cannot confirm friendship" do
        allow_any_instance_of(Friendship).to receive(:accepted!).and_return(false)
        patch confirm_friendship_path(friendship)
        expect(flash[:alert]).to eq(I18n.t("friendships.confirm.error"))
        expect(response).to redirect_to(friends_path)
      end

      it "returns 404 if friendship not found" do
        patch confirm_friendship_path("non-existent-id")
        expect(response).to have_http_status(:not_found).or redirect_to(root_path)
      end

      it "show flash message if friendship not found and redirects" do
        patch confirm_friendship_path("non-existent-id")
        expect(flash[:alert]).to eq(I18n.t("errors.messages.not_found"))
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not logged in' do
      it "redirects to sign in page" do
        patch confirm_friendship_path(friendship)
        expect(response).to redirect_to(new_user_session_path)
        expect(friendship.reload.status).to eq("pending")
      end
    end
  end
end
