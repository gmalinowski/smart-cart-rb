class CreateInvitationLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :invitation_links, id: :uuid do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }, null: false, type: :uuid
      t.uuid :token, null: false, default: SecureRandom.uuid, index: { unique: true }
      t.integer :max_uses, null: false, default: 1
      t.integer :uses_count, null: false, default: 0
      t.timestamp :expires_at, null: false, default: -> { "CURRENT_TIMESTAMP + INTERVAL '30 days'" }

      t.timestamps
    end
  end
end
