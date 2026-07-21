class CreateLoanDecisions < ActiveRecord::Migration[8.1]
  def change
    create_table :loan_decisions do |t|
      t.references :loan_application, null: false, foreign_key: true, index: { unique: true }
      t.string :decision, null: false
      t.decimal :interest_rate, precision: 5, scale: 2
      t.text :reason, null: false

      t.timestamps
    end
  end
end
