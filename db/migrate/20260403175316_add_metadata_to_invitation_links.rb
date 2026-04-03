class AddMetadataToInvitationLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :invitation_links, :metadata, :jsonb, default: {}, null: false

    add_index :invitation_links,
              "user_id, (metadata->>'recipient_email')",
              unique: true,
              using: :btree,
              where: "(metadata->>'recipient_email') IS NOT NULL AND invitation_type = 1",
              name: "index_invitation_links_on_user_id_and_recipient_email"
  end
end
