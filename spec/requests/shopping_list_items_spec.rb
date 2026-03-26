require 'rails_helper'

RSpec.describe "ShoppingListItems", type: :request do
  describe "GET /shopping_lists/:shopping_list_id/shopping_list_items" do
    let (:user) { create(:user) }
    let(:list_with_items) do
      list = create(:shopping_list, owner: user)
      list.shopping_list_items.create!(name: 'milk', checked: true)
      list.shopping_list_items.create!(name: 'eggs')
      list.shopping_list_items.create!(name: 'butter', checked: true)
      list.shopping_list_items.create!(name: 'bread')
      list
    end
    before { sign_in_with_session user }
    it 'renders unchecked items before checked items' do
      list = list_with_items
      get shopping_list_path(list)
      body = response.body
      expect(body.index('eggs')).to be < body.index('milk')
      expect(body.index('bread')).to be < body.index('butter')
    end
  end
  describe "POST /shopping_lists/:shopping_list_id/shopping_list_items" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      let(:list) { create(:shopping_list, owner: user) }
      before { sign_in_with_session user }

      it 'adds item to shopping list' do
        post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: 'milk' } }
        expect(list.reload.shopping_list_items.count).to eq(1)
      end

      it 'does not create item with invalid params' do
        expect {
          post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: '' } }
        }.not_to change(list.shopping_list_items, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns turbo stream with form reset' do
        post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: 'milk' }, format: :turbo_stream }
        expect(response.body).to include('turbo-stream')
        expect(response.body).to include('replace')
      end

      it 'redirects to shopping list page' do
        list = create(:shopping_list, owner: user)
        expect {
          post shopping_list_shopping_list_items_path(list), params: { shopping_list_item: { name: 'milk' } }
        }.to change(list.shopping_list_items, :count).by(1)
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

  describe "PUT /shopping_lists/:shopping_list_id/shopping_list_items/:id" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }
      it 'updates item name' do
        list = create(:shopping_list, owner: user)
        item = list.shopping_list_items.create!(name: 'milk')
        put shopping_list_shopping_list_item_path(list, item), params: { shopping_list_item: { name: 'eggs' } }
        expect(item.reload.name).to eq('eggs')
      end
    end
    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        list = create(:shopping_list)
        item = list.shopping_list_items.create!(name: 'milk')
        put shopping_list_shopping_list_item_path(list, item), params: { shopping_list_item: { name: 'eggs' } }
        expect(response).to redirect_to(new_user_session_path)
        end
      end
  end

  describe "PATCH /shopping_lists/:shopping_list_id/shopping_list_items/:id/toggle" do
    let(:user) { create(:user) }
    let(:list) { create(:shopping_list, owner: user) }
    let(:item) { list.shopping_list_items.create!(name: 'milk') }
    context 'when user is logged out' do
      it 'redirects to sign in page' do
        patch toggle_shopping_list_shopping_list_item_path(list, item)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it 'checks list item' do
        patch toggle_shopping_list_shopping_list_item_path(list, item)
        expect(item.reload.checked).to be_truthy
      end
      it 'unchecks list item' do
        item.update!(checked: true)
        patch toggle_shopping_list_shopping_list_item_path(list, item)
        expect(item.reload.checked).to be_falsey
      end
    end
  end

  describe "DELETE /shopping_lists/:shopping_list_id/shopping_list_items/:id" do
    context 'when user is logged in' do
      let(:user) { create(:user) }
      before { sign_in_with_session user }
      it 'deletes item from shopping list' do
        list = create(:shopping_list, owner: user)
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
