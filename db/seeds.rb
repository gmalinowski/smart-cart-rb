# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user_1 = User.create!(email: "user_1@example.com", password: "password", password_confirmation: "password", confirmed_at: Time.zone.now)
user_2 = User.create!(email: "user_2@example.com", password: "password", password_confirmation: "password", confirmed_at: Time.zone.now)
user_3 = User.create!(email: "user_3@example.com", password: "password", password_confirmation: "password", confirmed_at: Time.zone.now)
user_4 = User.create!(email: "user_4@example.com", password: "password", password_confirmation: "password", confirmed_at: Time.zone.now)
user_unconfirmed = User.create!(email: "unconfirmed@example.com", password: "password", password_confirmation: "password")

shopping_1_1 = ShoppingList.create!(name: "My Shopping List", owner: user_1)
shopping_1_2 = ShoppingList.create!(name: "Tools", owner: user_1)
shopping_1_3 = ShoppingList.create!(name: "My Other Shopping List", owner: user_1)
shopping_2_1 = ShoppingList.create!(name: "My Other Shopping List", owner: user_2)

shopping_1_1.shopping_list_items.create!(name: "Milk")
shopping_1_1.shopping_list_items.create!(name: "Eggs")
shopping_1_2.shopping_list_items.create!(name: "Hammer")
shopping_1_3.shopping_list_items.create!(name: "Bread")
shopping_2_1.shopping_list_items.create!(name: "Bread")

group_1_1 = Group.create!(name: "My Group", owner: user_1)
group_1_2 = Group.create!(name: "My Other Group", owner: user_1)
group_1_1.shopping_lists << shopping_1_1
group_1_2.shopping_lists << shopping_1_2

group_2_1 = Group.create!(name: "Funny group", owner: user_2)

Friendship.create!(user: user_1, friend: user_2, status: :accepted)
Friendship.create!(user: user_4, friend: user_1, status: :accepted)
Friendship.create!(user: user_1, friend: user_3, status: :pending)
Friendship.create!(user: user_2, friend: user_4, status: :accepted)
