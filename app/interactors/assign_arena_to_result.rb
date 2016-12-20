class AssignArenaToResult
  include Interactor

  def call
    result = context.result
    user = result.user

    context.fail! unless result.arena?

    latest_arena = user.arenas.order(:created_at).last
    if latest_arena && latest_arena.hero == result.hero &&
      latest_arena.wins.count < 12 && latest_arena.losses.count < 3
    then
      result.arena = latest_arena
    else
      result.build_arena(hero: result.hero, user: user)
    end

    context.arena = result.arena
  end
end
