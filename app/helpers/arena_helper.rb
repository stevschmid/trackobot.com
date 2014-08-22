module ArenaHelper
  def arena_result(arena)
    content_tag(:span, pluralize(arena.wins.count, 'win'), class: 'arena-wins justified')
  end
end
