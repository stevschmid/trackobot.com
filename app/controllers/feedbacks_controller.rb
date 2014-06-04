class FeedbacksController < ApplicationController
  def new
    @feedback = current_user.feedbacks.new
  end

  def create
    @feedback = current_user.feedbacks.create(feedback_params)
    if @feedback.save
      flash[:success] = "A pigeon was sent off with your feedback. Thank you!"
      redirect_to profile_history_index_path
    else
      render :new
    end
  end


  private

  def feedback_params
    params.require(:feedback).permit(:message)
  end
end
