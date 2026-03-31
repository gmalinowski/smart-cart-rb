class ChangeDefaultTokenInInvitationLinks < ActiveRecord::Migration[8.1]
  def change
    change_column_default :invitation_links, :token, from: SecureRandom.uuid, to: -> { 'gen_random_uuid()' }
  end
end
