 
class CreateIssueNotifierLogs < ActiveRecord::Migration[6.0]
    def change
      create_table :issue_notifier_logs do |t|
        t.references :issue, null: false, foreign_key: true
        t.text :message
        t.timestamps
      end
    end
  end
  