require 'rails_helper'

RSpec.describe 'Folder', type: :request do
  describe 'GET /folder' do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }
      it 'returns success' do
        get folder_path
        expect(response).to have_http_status(:success)
      end

      it 'loads drafts' do
        draft = CreateShoppingListWithItem.new(item_name: 'test', owner_id: user.id).call
        get folder_path
        expect(assigns(:drafts)).to include(draft)
      end

      it 'loads groups' do
        group = create(:group, owner_id: user.id)
        get folder_path
        expect(assigns(:groups)).to include(group)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        get folder_path
        expect(response).to redirect_to(new_user_session_path)
        end
    end
  end
end
