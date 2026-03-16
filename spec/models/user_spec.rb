require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'session_version' do
    it 'should be incremented when password is changed' do
      user = create(:user)
      expect {
        user.update(password: 'P@assword12', password_confirmation: 'P@assword12')
      }.to change { user.session_version }.by(1)
    end

    it 'does not increment when other attributes change' do
      user = create(:user)
      expect {
        user.update(email: '1234@ggg.com')
      }.not_to change { user.session_version }
    end
  end
end
