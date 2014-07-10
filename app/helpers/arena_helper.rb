module ArenaHelper
  def arena_result(arena)
    pluralize(arena.wins.count, 'win')
  end
end
