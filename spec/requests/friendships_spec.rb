require 'rails_helper'

RSpec.describe "Friendships", type: :request do
  describe "POST /friendships" do
    let(:user) { create(:user) }
    let(:friend) { create(:user) }

    context 'when user is logged in' do
      before { sign_in_with_session user }
      context 'when friend is signed up' do
        it "calls Pundit authorization for Friendship" do
          expect_any_instance_of(FriendshipsController).to receive(:authorize)
                                                             .with(:friendship, :create?)
                                                             .and_call_original

          post friendships_path, params: { friendship_invitation: { email: friend.email } }
        end

        context 'when service returns success' do
          it "redirects to friends page with success flash" do
            post friendships_path, params: { friendship_invitation: { email: friend.email } }, as: :turbo_stream
            expect(response).to redirect_to(friends_path)
            expect(flash[:success]).to eq(I18n.t("friendships.create.success"))
          end
        end

        context 'when service returns failure' do
          it "redirects to friends page with error flash" do
            allow_any_instance_of(InviteFriendService).to receive(:call).and_return({
                                                                                              success: false,
                                                                                              errors: ["Email is invalid", "Already invited"]
                                                                                            })
            post friendships_path, params: { friendship_invitation: { email: friend.email } }, as: :turbo_stream
            expect(response).to redirect_to(friends_path)
            expect(flash[:alert]).to eq("Email is invalid and Already invited")
          end
        end

        context 'when params are invalid (e.g. empty email)' do
          it "renders the new template" do
            post friendships_path, params: { friendship_invitation: { email: "" } }, as: :turbo_stream
            expect(response).to have_http_status(:unprocessable_content)
            expect(response).to render_template(:new)
          end
        end

        context 'when Pundit denies access' do
          before do
            allow_any_instance_of(FriendshipPolicy).to receive(:create?).and_return(false)
          end

          it "redirects or shows error" do
            post friendships_path, params: { friendship_invitation: { email: friend.email } }
            expect(response).to have_http_status(:redirect)
            expect(flash[:alert]).not_to be_nil
          end
        end
      end
    end

    # context 'when friend is not signed up' do
    #
    #
    #
    #   it 'shows flash message for successful email invitation' do
    #     post friendships_path, params: { friendship_invitation: { email: "test@example.com" } }
    #     expect(response).to redirect_to(friends_path)
    #     expect(flash[:notice]).to eq(I18n.t("friendships.create.email_invitation_sent"))
    #   end
    #
    #

    #
    #     it 'shows flash message when something goes wrong' do
    #       allow_any_instance_of(InvitationLink).to receive(:save).and_return(false)
    #       post friendships_path, params: { friendship_invitation: { email: friend.email } }
    #       expect(response).to redirect_to(friends_path)
    #       expect(flash[:alert]).to eq(I18n.t("friendships.create.error"))
    #     end
    #
    # end

    context 'when user is not logged in' do
      it "redirects to sign in page" do
        expect {
          post friendships_path, params: { friend_id: friend.id }
        }.not_to change(Friendship, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /friendships/destroy_by_friend/:friend_id" do
    let(:user) { create(:user) }
    let(:friend) { create(:user) }
    let!(:friendship) { create(:friendship, user: friend, friend: user, status: :accepted) }
    context 'when user is logged in' do
      before { sign_in_with_session user }

      it "successfully deletes the friendship by finding it through friend_id" do
        expect {
          delete destroy_by_friend_friendships_path(friend_id: friend.id)
        }.to change(Friendship, :count).by(-1)
        expect(response).to redirect_to(friends_path)
        expect(flash[:warning]).to eq(I18n.t("friendships.destroy.success"))
      end

      it "returns 404/redirect when users exist but have no friendship" do
        stranger = create(:user)
        expect {
          delete destroy_by_friend_friendships_path(friend_id: stranger.id)
        }.not_to change(Friendship, :count)

        expect(response).to have_http_status(:redirect).or have_http_status(:not_found)
        expect(flash[:alert]).to be_present
      end

      it "delegates to destroy and sets the correct flash for pending status" do
        friendship.update(status: :pending)

        delete destroy_by_friend_friendships_path(friend_id: friend.id)

        expect(response).to redirect_to(friends_path)
        expect(flash[:warning]).to eq(I18n.t("friendships.destroy.request.success"))
      end

      it "raises redirect when friend_id is invalid" do
        expect {
          delete destroy_by_friend_friendships_path(friend_id: 999_999)
        }.not_to change(Friendship, :count)
        expect(response).to have_http_status(:not_found).or have_http_status(:redirect)
        expect(flash[:alert]).to be_present
      end

      it "returns 404/redirect when trying to delete a non-existent friendship" do
        other_user = create(:user)
        expect {
          delete destroy_by_friend_friendships_path(friend_id: other_user.id)
        }.not_to change(Friendship, :count)

        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to eq(I18n.t("errors.messages.not_found"))
      end

      it "prevents deleting a friendship of two other users (security check)" do
        user_a = create(:user)
        user_b = create(:user)
        create(:friendship, user: user_a, friend: user_b, status: :accepted)
        expect {
          delete destroy_by_friend_friendships_path(friend_id: user_a.id)
        }.not_to change(Friendship, :count)
        expect(response).to have_http_status(:redirect)
      end
    end
    context 'when user is not logged in' do
      it "redirects to sign in page" do
        expect {
          delete destroy_by_friend_friendships_path(friend)
        }.not_to change(Friendship, :count)
        expect(response).to have_http_status(:found) # 302 redirect
      end
    end
  end

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

  describe "GET /friendships/new" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }

      context 'turbo stream' do
        it "renders new friendship form" do
          get new_friendship_path(format: :turbo_stream)
          expect(response.content_type).to include("text/vnd.turbo-stream.html")
          expect(response).to have_http_status(:success)
          expect(response.body).to include("form")
        end

        it "has assigned new FriendshipInvitation object" do
          get new_friendship_path(format: :turbo_stream)
          expect(assigns(:friendship_invitation)).to be_present
        end

        it "has email field" do
          get new_friendship_path(format: :turbo_stream)
          expect(response.body).to include('type="email"')
        end
      end
    end

    context 'when user is not logged in' do
      it "redirects to sign in page" do
        get new_friendship_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
