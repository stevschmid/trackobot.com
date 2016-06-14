class AddNoteToResults < ActiveRecord::Migration
  def up
    add_column :results, :note, :string

    # migrate existing tags
    Result.joins(:tags).uniq.each do |result|
      result.update_attributes(note: result.tags.collect(&:tag).join(', '))
    end
  end

  def down
    remove_column :results, :note
  end
end
