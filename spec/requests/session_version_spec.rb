require 'rails_helper'

RSpec.describe 'Session Version', type: :request do
  it 'log out user when session_version is stale' do
    user = create(:user)
    sign_in_with_session user
    user.increment!(:session_version)
    get edit_user_registration_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'user can log in' do
    user = create(:user)
    sign_in user
    get root_path
    expect(response).to have_http_status(:success)
  end
end
