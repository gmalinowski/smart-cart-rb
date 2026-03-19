require 'rails_helper'
RSpec.describe "ShoppingLists", type: :request do
  describe "GET /shopping_lists/:id" do
    it "returns http success" do
      list = create(:shopping_list)
      get shopping_list_path(list)
      expect(response).to have_http_status(:success)
    end
    it "assigns @list" do
      list = create(:shopping_list)
      get shopping_list_path(list)
      expect(assigns(:shopping_list)).to eq(list)
    end
    it "assigns @shopping_list_item" do
      list = create(:shopping_list)
      get shopping_list_path(list)
      expect(assigns(:shopping_list_item)).to be_a_new(ShoppingListItem)
    end
  end

  describe "POST /list_items" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }

      it 'creates a new shopping list with the item' do
        post shopping_lists_path, params: { shopping_list_item: { name: 'milk' } }
        expect(ShoppingListItem.count).to eq(1)
        expect(ShoppingList.count).to eq(1)
      end

      it 'redirects to edit shopping list after creation' do
        post shopping_lists_path, params: { shopping_list_item: { name: 'milk' } }
        expect(response).to redirect_to(shopping_list_path(ShoppingList.last))
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        post shopping_lists_path, params: { shopping_list_item: { name: 'milk' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
