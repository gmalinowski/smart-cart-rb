class AddConstraintUserCanNotBeFriendToFriendships < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :friendships, "user_id != friend_id", name: "friendships_no_self_reference"
  end
end
