class AddInvitationTypeToInvitationLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :invitation_links, :invitation_type, :integer, default: 0, null: false
  end
end
