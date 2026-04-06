require 'rails_helper'
RSpec.describe "InvitationLinks", type: :request do
  let(:user) { create(:user) }

  describe "authorization check" do
    describe 'accept action' do
      before { sign_in_with_session user }
      context 'when there is no pending request' do
        let!(:invitation_link) { create(:invitation_link, user: user) }
        it 'calls pundit auth for InvitationLink:accept' do
          expect_any_instance_of(InvitationLinksController).to receive(:authorize)
                                                                 .with(instance_of(InvitationLink), :accept?)
                                                                 .and_call_original
          get accept_invitation_link_path(invitation_link.token)
        end
      end

      context 'when there is a pending request and user is inviter' do
        let!(:friend) { create(:user) }
        let!(:invitation_link) { create(:invitation_link, user: friend) }
        let!(:friendship) { create(:friendship, user: user, friend: friend, status: :pending) }

        it 'authorizes both the link and the auto-confirmation' do
          expect_any_instance_of(InvitationLinksController).to receive(:authorize)
                                                                 .with(instance_of(InvitationLink), :accept?)
                                                                 .and_call_original

          expect_any_instance_of(InvitationLinksController).to receive(:authorize)
                                                                 .with(instance_of(Friendship), :auto_confirm?)
                                                                 .and_call_original

          get accept_invitation_link_path(invitation_link.token)

          expect(friendship.reload.status).to eq("accepted")
        end
      end

    end
  end

  describe "POST /invitation_links" do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "creates a new invitation link" do
        expect {
          post invitation_links_path
        }.to change(InvitationLink, :count).by(1)
      end

      it "set errored flash message if link could not be created" do
        allow_any_instance_of(InvitationLink).to receive(:save).and_return(false)
        post invitation_links_path
        expect(flash[:alert]).to eq(I18n.t("invitation_links.create.error"))
      end

      context 'turbo stream' do
        it "renders turbo stream" do
          post invitation_links_path, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(response.body).to include("turbo-stream")
        end
        it "has assigned invitation link" do
          post invitation_links_path, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          expect(assigns(:invitation_link)).to eq(InvitationLink.last)
        end
      end
    end

    context 'when user is not logged in' do
      it "redirects to sign in page" do
        expect {
          post invitation_links_path
        }.to change(InvitationLink, :count).by(0)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /invitation_links/:id" do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "deletes invitation link" do
        link = create(:invitation_link, user: user)
        expect {
          delete invitation_link_path(link)
        }.to change(InvitationLink, :count).by(-1)
      end
    end
    context 'when user is not logged in' do
      it "redirects to sign in page" do
        link = create(:invitation_link, user: user)
        expect {
          delete invitation_link_path(link)
        }.to change(InvitationLink, :count).by(0)
      end
    end
  end

  describe "[Accept invitation] GET /invitation_links/:id/accept" do
    context 'when user is logged in' do
      let(:inviter_user) { create(:user) }
      before { sign_in_with_session user }

      describe "auto-accepting" do
        context 'when pending friendship already created by invitee' do
          let!(:friendship) { create(:friendship, user: user, friend: inviter_user, status: :pending) }

          it "accepts invitation" do
            link = create(:invitation_link, user: inviter_user)
            expect {
              get accept_invitation_link_path(link.token)
            }.to change(Friendship, :count).by(0)
            expect(friendship.reload.status).to eq("accepted")
          end

          it "redirects with success" do
            link = create(:invitation_link, user: inviter_user)
            get accept_invitation_link_path(link.token)
            expect(response).to redirect_to(friends_path)
            expect(flash[:success]).to eq(I18n.t("friendships.confirm.success"))

          end
        end
        context 'when pending friendship already created by inviter' do
          let!(:friendship) { create(:friendship, user: inviter_user, friend: user, status: :pending) }

          it "does not accept invitation" do
            link = create(:invitation_link, user: inviter_user)
            expect {
              get accept_invitation_link_path(link.token)
            }.to change(Friendship, :count).by(0)
            expect(friendship.reload.status).to eq("pending")
          end
        end
      end

      it "renders accept view" do
        link = create(:invitation_link, user: inviter_user)
        get accept_invitation_link_path(link.token)
        expect(response).to render_template(:accept)
      end

      it "increases invitation link uses count" do
        link = create(:invitation_link, user: inviter_user)
        expect {
          get accept_invitation_link_path(link.token)
        }.to change { link.reload.uses_count }.by(1)
      end

      it "creates pending friendship" do
        link = create(:invitation_link, user: inviter_user)
        expect {
          get accept_invitation_link_path(link.token)
        }.to change(Friendship, :count).by(1)
        expect(Friendship.last.status).to eq("pending")
      end

      it "has assigned user which has created invitation" do
        link = create(:invitation_link, user: inviter_user)
        get accept_invitation_link_path(link.token)
        expect(assigns(:inviter)).to eq(inviter_user)
      end

      it "has assigned invitee user" do
        link = create(:invitation_link, user: inviter_user)
        get accept_invitation_link_path(link.token)
        expect(assigns(:invitee)).to eq(user)
      end

      it "has assigned friendship" do
        link = create(:invitation_link, user: inviter_user)
        get accept_invitation_link_path(link.token)
        expect(assigns(:friendship)).to be_present
      end

      it "assigned friendship is not valid if users are already friends" do
        link = create(:invitation_link, user: inviter_user)
        create(:friendship, user: user, friend: inviter_user, status: :accepted)
        get accept_invitation_link_path(link.token)
        expect(assigns(:friendship)).not_to be_valid
      end

      it "redirects with error flash if token is invalid" do
        get accept_invitation_link_path("invalid_token")
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(root_path)
      end

      it "redirects with error flash if inviter is not found" do
        link = create(:invitation_link, user: user)
        user.destroy
        get accept_invitation_link_path(link.token)
        expect(flash[:alert]).to be_present
      end

      it "redirects with error flash if invitee is not found" do
        link = create(:invitation_link, user: inviter_user)
        inviter_user.destroy
        get accept_invitation_link_path(link.token)
        expect(flash[:alert]).to be_present
      end

      it "redirects with notice if user tries to accept own invitation" do
        link = create(:invitation_link, user: user)
        get accept_invitation_link_path(link.token)
        expect(flash).not_to be_empty
        expect(response).to redirect_to(root_path)
      end

      it "redirects with notice if token is expired" do
        link = create(:invitation_link, user: inviter_user, expires_at: 1.day.ago)
        get accept_invitation_link_path(link.token)
        expect(flash).not_to be_empty
        expect(response).to redirect_to(root_path)
      end

      it "redirects with notice if token max usage is reached" do
        link = create(:invitation_link, user: inviter_user, max_uses: 1, uses_count: 1)
        get accept_invitation_link_path(link.token)
        expect(flash).not_to be_empty
        expect(response).to redirect_to(root_path)
      end

      it "redirects with flash msg if friendship is pending by inviter_user" do
        link = create(:invitation_link, user: inviter_user)
        create(:friendship, user: inviter_user, friend: user, status: :pending)
        get accept_invitation_link_path(link.token)
        expect(flash).not_to be_empty
        expect(response).to redirect_to(root_path)
      end

    end
    context 'when user is not logged in' do
      it "redirects to sign in page" do
        link = create(:invitation_link, user: create(:user))
        get accept_invitation_link_path(link.token)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
