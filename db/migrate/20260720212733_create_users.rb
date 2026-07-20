class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.decimal :income, precision: 12, scale: 2
      t.string :employment_status, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end