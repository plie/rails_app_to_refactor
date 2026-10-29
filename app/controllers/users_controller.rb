# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)

    password = user_params[:password].to_s.strip
    password_confirmation = user_params[:password_confirmation].to_s.strip

    errors = {}
    errors[:password] = ["can't be blank"] if password.blank?
    errors[:password_confirmation] = ["can't be blank"] if password_confirmation.blank?

    if errors.present?
      render_json(422, user: errors)
    else
      if password != password_confirmation
        render_json(422, user: { password_confirmation: ["doesn't match password"] })
      else
        password_digest = Digest::SHA256.hexdigest(password)
        # notice not using bcrypt for password hashing. Bcrypt adds a salt and a time cost to make hacking costly (but behavior change)
        # bcrypt would also simplify this flow - can remove the stripping, confirmation comparison and checking blanks
        user = User.new(
          name: user_params[:name],
          email: user_params[:email],
          token: SecureRandom.uuid, # token viewable in plain site - better to be hashed
          password_digest: password_digest # not yet using password - might not be needed if the client already knows the user
        )

        if user.save
          render_json(201, user: user.as_json(only: [:id, :name, :token]))
        else
          render_json(422, user: user.errors.as_json)
        end
      end
    end
  end

  def show
    perform_if_authenticated
  end

  def destroy
    perform_if_authenticated do
      current_user.destroy
    end
  end

  private

    def perform_if_authenticated(&block)
      authenticate_user do
        block.call if block

        render_json(200, user: { email: current_user.email })
      end
    end
end
