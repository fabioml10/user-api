class Api::V1::UsersController < ApplicationController

  def index
    user = User.all
    render json: user, status: :ok
  end

  def show
    user = User.find_by(id: params[:id])

    if user
      render json: [user], status: :ok
    else
      render json: { errors: "User not found." }, status: :not_found
    end
  end

  def create
    user = User.new(user_params)
  
    if user.save
      render json: {status: 'User created successfully.'}, status: :created
    else
      render json: { errors: user.errors.full_messages[0] }, status: :bad_request
    end
  end

  def destroy
    begin
      payload = JsonWebToken.decode(user_params[:token])[0]

      if JsonWebToken.valid_payload(payload)
        user_id = JsonWebToken.decode(user_params[:token])[0]['user_id'].to_i

        if user_id === params[:id].to_i
          user = User.find(params[:id])

          if user.present?
            if user.delete
              render json: {status: 'User deleted.'}, status: :ok
            else
              render json: { errors: user.errors.full_messages[0] }, status: :bad_request
            end
          else
            render json: {error: 'User could not be found.'}, status: :not_found
          end
        else
          render json: {error: 'User coud not be identified.'}, status: :bad_request
        end
      else
        render json: {error: 'Invalid token.'}, status: :unauthorized
      end
    rescue
      render json: {error: 'Invalid token format.'}, status: :bad_request
    end
    
  end

  def login
    user = User.find_by(email: user_params[:email].to_s.downcase)
  
    if user && user.authenticate(user_params[:password])
      auth_token = JsonWebToken.encode({user_id: user.id})
      render json: {auth_token: auth_token}, status: :ok
    else
      render json: {error: 'Invalid credentials.'}, status: :unauthorized
    end
  end

  def change
    begin
      payload = JsonWebToken.decode(user_params[:token])[0]

      if JsonWebToken.valid_payload(payload)
        user_id = JsonWebToken.decode(user_params[:token])[0]['user_id'].to_i
        if user_id
          user = User.find(user_id)

          if user.present?
            if user.update password: user_params[:password], password_confirmation: user_params[:password_confirmation]
              render json: {status: 'Password changed.'}, status: :ok
            else
              render json: {error: user.errors.full_messages[0]}, status: :bad_request
            end
          else
            render json: {error: 'Invalid username / password'}, status: :not_found
          end
        else
          render json: {error: 'User not found.'}, status: :bad_request
        end
      else
        render json: {error: 'Invalid token.'}, status: :unauthorized
      end
    rescue
      render json: {error: 'Invalid token format.'}, status: :bad_request
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :token)
    end

end
