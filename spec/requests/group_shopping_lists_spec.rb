require 'rails_helper'

RSpec.describe "GroupShoppingLists", type: :request do
  let(:user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }

  describe "GET /shopping_lists/:id/group_shopping_lists/edit" do
    context 'when user is logged in' do
      before { sign_in_with_session user }
      it "returns http success" do
        get edit_shopping_list_group_shopping_lists_path(shopping_list)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it "redirects to sign in page" do
        get edit_shopping_list_group_shopping_lists_path(shopping_list)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
