module AuthHelpers
  def sign_in_with_session(user)
    post new_user_session_path,
         params: { user: { email: user.email, password: user.password } }
  end
end
