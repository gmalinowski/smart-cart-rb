require 'rails_helper'

RSpec.describe "GroupShoppingLists", type: :request do
  let(:user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }
  let(:group) { create(:group, owner: user) }
  let(:group2) { create(:group, owner: user) }
  let(:group3) { create(:group, owner: user) }
  let(:group_shopping_list) { create(:group_shopping_list, group: group, shopping_list: shopping_list) }

  describe "PATCH /shopping_lists/:id/group_shopping_lists" do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "assigns shopping_list to multiple groups" do
        params = { shopping_list: { group_ids: [ group.id, group2.id, group3.id ] } }
        patch shopping_list_group_shopping_lists_path(shopping_list), params: params
        expect(shopping_list.reload.groups).to match_array([ group, group2, group3 ])
      end
      it "assigns shopping_list to a single group" do
        params = { shopping_list: { group_ids: [ group2.id ] } }
        patch shopping_list_group_shopping_lists_path(shopping_list), params: params
        expect(shopping_list.reload.groups).to eq([ group2 ])
      end
      it "removes shopping_list from all groups" do
        params = { shopping_lists: { group_ids: [] } }
        patch shopping_list_group_shopping_lists_path(shopping_list), params: params
        expect(shopping_list.reload.groups).to eq([])
      end
      it "redirects to shopping_list page with flash message" do
        patch shopping_list_group_shopping_lists_path(shopping_list), params: { shopping_list: { group_ids: [ group.id ] } }
        expect(response).to redirect_to(shopping_list_path(shopping_list))
        expect(flash).to_not be_empty
      end

      context 'when validation fails' do
        before do
          allow_any_instance_of(ShoppingList).to receive(:update).and_return(false)
          allow_any_instance_of(ActiveModel::Errors).to receive(:full_messages).and_return([ "Artificial error" ])
        end

        it 'renders edit form with status 422' do
          patch shopping_list_group_shopping_lists_path(shopping_list), params: { shopping_list: { group_ids: [ group.id ] } }
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template(:edit)
        end

        it "ensure @groups is assigned" do
          patch shopping_list_group_shopping_lists_path(shopping_list), params: { shopping_list: { group_id: group.id } }
          expect(assigns(:groups)).to eq([ group ])
        end

        it "should display error message" do
          patch shopping_list_group_shopping_lists_path(shopping_list), params: { shopping_list: { group_id: group.id } }
          expect(flash).to_not be_empty
        end
      end
      it "does not allow user to assign shopping_list to group they are not a member of"
    end
    context 'when user is not logged in' do
        it "redirects to sign in page" do
          patch shopping_list_group_shopping_lists_path(shopping_list), params: { shopping_list: { group_id: group.id } }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
  end

  describe "GET /shopping_lists/:id/group_shopping_lists/edit" do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "returns http success" do
        get edit_shopping_list_group_shopping_lists_path(shopping_list)
        expect(response).to have_http_status(:success)
      end

      it "assigns @shopping_list" do
        get edit_shopping_list_group_shopping_lists_path(shopping_list)
        expect(assigns(:shopping_list)).to eq(shopping_list)
      end
      it "assigns @group_shopping_lists" do
        get edit_shopping_list_group_shopping_lists_path(shopping_list)
        expect(assigns(:group_shopping_lists)).to eq(shopping_list.group_shopping_lists)
      end
      it "assigns @groups owned by user" do
        get edit_shopping_list_group_shopping_lists_path(shopping_list)
        expect(assigns(:groups)).to eq(user.groups)
      end

      it "assigns @groups in which the user is a member"
    end

    context 'when user is not logged in' do
      it "redirects to sign in page" do
        get edit_shopping_list_group_shopping_lists_path(shopping_list)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
