require 'rails_helper'

RSpec.describe "ShoppingListItems", type: :request do
  describe "POST /shopping_lists/:shopping_list_id/shopping_list_items" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }

      it 'adds item to shopping list' do
        list = create(:shopping_list)
        post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: 'milk' } }
        expect(list.shopping_list_items.count).to eq(1)
      end

      it 'returns turbo stream with form reset' do
        list = create(:shopping_list)
        post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: 'milk' }, format: :turbo_stream }
        expect(response.body).to include('turbo-stream')
        expect(response.body).to include('replace')
      end

      it 'redirects to shopping list page' do
        list = create(:shopping_list)
        post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: 'milk' } }
        expect(response).to redirect_to(shopping_list_path(list))
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        list = create(:shopping_list)
        post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: 'milk' } }
        expect(response).to redirect_to(new_user_session_path)
        end
    end
  end

  describe "DELETE /shopping_lists/:shopping_list_id/shopping_list_items/:id" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }
      it 'deletes item from shopping list' do
        list = create(:shopping_list)
        item = list.shopping_list_items.create!(name: 'milk')
        expect {
          delete shopping_list_shopping_list_item_path(list, item)
        }.to change(list.shopping_list_items, :count).by(-1)
        expect(response).to have_http_status(:success)
      end
    end
    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        list = create(:shopping_list)
        item = list.shopping_list_items.create!(name: 'milk')
        delete shopping_list_shopping_list_item_path(list, item)
        expect(response).to redirect_to(new_user_session_path)
        end
      end
  end
end
