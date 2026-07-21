class CreateCreditProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :credit_score, null: false
      t.decimal :debt_to_income, precision: 5, scale: 2, null: false
      t.integer :bankruptcies, null: false, default: 0

      t.timestamps
    end
  end
end
