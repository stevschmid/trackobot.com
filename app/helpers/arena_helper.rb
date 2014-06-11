module ArenaHelper
  def arena_result(arena)
    [ arena.wins.count, arena.losses.count ].join('-')
  end
end
