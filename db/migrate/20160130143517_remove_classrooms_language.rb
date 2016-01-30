class RemoveClassroomsLanguage < ActiveRecord::Migration[5.0]
  def change
    remove_column :classrooms, :language
  end
end
