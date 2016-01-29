class CreateParchments < ActiveRecord::Migration[5.0]
  def change
    create_table :parchments do |t|
      t.integer :classroom_id
      t.text :content
      t.string :path

      t.timestamps
    end
  end
end
