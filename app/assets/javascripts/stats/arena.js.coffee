# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

update_arena_stats_win_distribution = (index) ->
  colors = ("#3498db" for [0..12])
  colors[index] = '#96d5ff' if index != null
  $('.arena-stats-win-distribution').data('fill', colors).peity('bar', fill: colors)

$(document).on 'ready page:load', ->
  update_arena_stats_win_distribution()

$(document).on "mouseover", ".arena-stats-select-win-bar", (e) ->
  update_arena_stats_win_distribution $(this).data('bar-index')

$(document).on "mouseout", ".arena-stats-select-win-bar", (e) ->
  update_arena_stats_win_distribution()
