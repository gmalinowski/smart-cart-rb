require 'rails_helper'

RSpec.describe 'Group', type: :request do
  let(:user) { create(:user) }

  describe 'GET /groups/:id' do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it 'returns success' do
        group = create(:group, owner: user)
        get group_path(group)
        expect(response).to have_http_status(:success)
        end
    end
    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        group = create(:group, owner: user)
        get group_path(group)
        expect(response).to redirect_to(new_user_session_path)
        end
      end
  end

  describe 'GET /groups/new' do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it 'renders new group form' do
        get new_group_path, headers: { "Accept" => "text/vnd.turbo-stream.html"}
        expect(response).to render_template(:new)
      end
      it 'assigns a new group with owner' do
        get new_group_path
        expect(assigns(:group)).to be_a_new(Group)
        expect(assigns(:group).owner).to eq(user)
        end
    end
    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        get new_group_path
        expect(response).to redirect_to(new_user_session_path)
        end
    end
  end

  describe 'delete /groups/:id' do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it 'deletes group' do
        group = create(:group, owner: user)
        expect {
          delete group_path(group)
        }.to change(Group, :count).by(-1)
        end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        group = create(:group, owner: user)
        expect {
          delete group_path(group)
        }.to change(Group, :count).by(0)
        expect(response).to redirect_to(new_user_session_path)
        end
      end
  end

  describe 'POST /groups' do
    context 'when user is logged in' do
      before { sign_in_with_session user }

      it 'redirects to group page' do
        post groups_path, params: { group: { name: 'test' } }
        expect(response).to redirect_to(group_path(Group.last))
      end

      it 'does not create a group with invalid params' do
        expect {
          post groups_path, params: { group: { name: '' } }, headers: { "Accept" => "text/vnd.turbo-stream.html"}
        }.not_to change(Group, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:new)
      end


      it 'creates a new group' do
        expect {
          post groups_path, params: { group: { name: 'test' } }
        }.to change(Group, :count).by(1)
      end

      it 'redirects to group page' do
        post groups_path, params: { group: { name: 'test' } }
        expect(response).to redirect_to(group_path(Group.last))
      end
    end
    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        post groups_path, params: { group: { name: 'test' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
