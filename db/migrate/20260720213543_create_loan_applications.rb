class CreateLoanApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :loan_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :purpose, null: false
      t.integer :term_months, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
    add_index :loan_applications, :status
  end
end
