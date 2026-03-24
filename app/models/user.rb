class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  before_save :update_session_version, if: :will_save_change_to_encrypted_password?

  has_many :shopping_lists, foreign_key: "owner_id"
  has_many :groups, foreign_key: "owner_id"


  private
  def update_session_version
    self.session_version += 1
  end
end
