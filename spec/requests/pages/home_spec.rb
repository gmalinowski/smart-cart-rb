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
      it 'has assigned owned groups with preloaded shopping lists and items' do
        group = create(:group, owner: user)
        shopping_list1 = create(:shopping_list, owner: user)
        shopping_list2 = create(:shopping_list, owner: user)
        create(:group_shopping_list, group: group, shopping_list: shopping_list1)
        create(:group_shopping_list, group: group, shopping_list: shopping_list2)
        create(:shopping_list_item, shopping_list: shopping_list1)
        create(:shopping_list_item, shopping_list: shopping_list2)
        get root_path
        expect(assigns(:groups)).to eq(user.groups)
        groups = assigns(:groups)
        expect(groups.first.association(:shopping_lists).loaded?).to be true
        shopping_lists = groups.first.shopping_lists
        expect(shopping_lists.first.association(:shopping_list_items).loaded?).to be true
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
