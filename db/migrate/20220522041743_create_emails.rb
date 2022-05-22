class CreateEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :emails do |t|
      t.references :user, null: false, foreign_key: true
      t.string :to, null: false
      t.string :subject, null: false
      t.text :body

      t.timestamps
    end
  end
end
