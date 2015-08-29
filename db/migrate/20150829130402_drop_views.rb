class DropViews < ActiveRecord::Migration
  def up
    drop_view :match_best_decks_with_results
    drop_view :match_decks_with_results
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
