class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
  end

  def create
    result = AuthenticateUser.call(session_params)

    if result.success?
      sign_in(result.user)
      redirect_to profile_path
    else
      flash.now[:error] = 'Invalid credentials'
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to new_sessions_path
  end

  private

  def session_params
    params.permit(:username, :password)
  end
end
