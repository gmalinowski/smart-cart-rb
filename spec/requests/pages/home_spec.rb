require 'rails_helper'

RSpec.describe 'Home', type: :request do
  let(:user) { create(:user) }
  describe 'GET /' do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it 'renders home page' do
        get root_path
        expect(response).to have_http_status(:success)
      end
      it 'has asigned groups' do
        create(:group, owner: user)
        get root_path
        expect(assigns(:groups)).to eq(user.groups)
      end
    end

    context 'when user is not logged in' do
      it 'renders home page' do
        get root_path
        expect(response).to have_http_status(:success)
      end
      it 'has no asigned groups' do
        get root_path
        expect(assigns(:groups)).to be_empty
        end
    end
  end
end
