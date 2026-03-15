require 'rails_helper'

RSpec.describe 'Session Version', type: :request do
  it 'log out user when session_version is stale' do
    user = create(:user)
    sign_in user
    user.increment!(:session_version)
    get root_path
    expect(response).to redirect_to(new_user_session_path)
  end
end