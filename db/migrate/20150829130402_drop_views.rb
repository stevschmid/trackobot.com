class DropViews < ActiveRecord::Migration
  def up
    if respond_to?(:drop_view)
      drop_view :match_best_decks_with_results
      drop_view :match_decks_with_results
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
