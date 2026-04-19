require 'rails_helper'
RSpec.describe "ShoppingLists", type: :request do
  describe "GET /shopping_lists/:id" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }
      it "returns http success" do
        list = create(:shopping_list, owner: user)
        get shopping_list_path(list)
        expect(response).to have_http_status(:success)
      end
      it "assigns @list" do
        list = create(:shopping_list)
        get shopping_list_path(list)
        expect(assigns(:shopping_list)).to eq(list)
      end
      it "assigns @shopping_list_item" do
        list = create(:shopping_list, owner: user)
        get shopping_list_path(list)
        expect(assigns(:empty_shopping_list_item)).to be_a_new(ShoppingListItem)
      end

      it "call Visits::track" do
        list = create(:shopping_list, owner: user)
        expect(Visits::Track).to receive(:call).with(user: user, shopping_list: list)
        get shopping_list_path(list)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        list = create(:shopping_list)
        get shopping_list_path(list)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not call Visits::track' do
        list = create(:shopping_list)
        expect(Visits::Track).to_not receive(:call)
        get shopping_list_path(list)
      end
    end
  end

  describe "DELETE /shopping_lists/:id" do
    context 'when user is logged out' do
      it 'redirects to sign in page' do
        list = create(:shopping_list)
        expect {
          delete shopping_list_path(list)
        }.to change(ShoppingList, :count).by(0)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }
      let(:shopping_list) { create(:shopping_list, owner: user) }
      let(:shopping_list_item) { create(:shopping_list_item, shopping_list: shopping_list) }

      it 'deletes the shopping list' do
        shopping_list
        shopping_list_item
        expect {
          delete shopping_list_path(shopping_list)
        }.to change(ShoppingList, :count).by(-1).and change(ShoppingListItem, :count).by(-1)
      end
      it 'redirects to shopping lists page' do
        delete shopping_list_path(shopping_list)
        expect(response).to redirect_to(root_path)
      end
      it 'user can not delete other users shopping list'
      it 'user can delete other user shopping list from owned group'

      it 'user can delete  other user shopping list if it is in group which he is member of'
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
