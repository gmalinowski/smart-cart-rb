
require 'rails_helper'
RSpec.describe "InvitationLinks", type: :request do
  let(:user) { create(:user) }
  describe "POST /invitation_links" do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "creates a new invitation link" do
        expect {
          post invitation_links_path
        }.to change(InvitationLink, :count).by(1)
      end

      it "set flash message after created" do
        post invitation_links_path
        expect(flash).to_not be_empty
      end

      it "set errored flash message if link could not be created" do
        allow_any_instance_of(InvitationLink).to receive(:save).and_return(false)
        post invitation_links_path
        expect(flash[:alert]).to be_present
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
end
