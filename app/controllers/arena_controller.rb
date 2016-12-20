class ArenaController < ApplicationController
  include Meta

  after_action :verify_policy_scoped
  after_action :verify_authorized

  def index
    @arenas = policy_scope(Arena).page(params[:page]).order('arenas.created_at DESC')

    if @arenas.any?
      @arenas.each { |arena| authorize arena, :show? }
    else
      skip_authorization
    end

    respond_to do |format|
      format.html
      format.json do
        render json: @arenas, meta: meta(@arenas), root: 'arena'
      end
    end
  end
end
