class AddNoteToResults < ActiveRecord::Migration
  def up
    add_column :results, :note, :string

    # migrate existing tags
    if defined?(Tag)
      Result.joins(:tags).uniq.each do |result|
        result.update_attributes(note: result.tags.collect(&:tag).join(', '))
      end
    end
  end

  def down
    remove_column :results, :note
  end
end
