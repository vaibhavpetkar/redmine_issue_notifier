 
module IssueNotifierHook
    class Hooks < Redmine::Hook::ViewListener
      def controller_issues_new_after_save(context={})
        check_and_send_notifications(context[:issue])
      end
  
      def controller_issues_edit_after_save(context={})
        check_and_send_notifications(context[:issue])
      end
  
      private
  
      def check_and_send_notifications(issue)
        return if issue.due_date.nil?
  
        remaining_days = (issue.due_date - Date.today).to_i
  
        if remaining_days == 5
          send_notification(issue)
        end
      end
  
      def send_notification(issue)
        settings = Setting.plugin_redmine_issue_notifier
        return if notification_sent_today?(issue)
  
        begin
          Mailer.issue_notification(issue).deliver
          log_notification(issue, 'Notification sent')
        rescue StandardError => e
          log_notification(issue, "Failed to send notification: #{e.message}")
        end
      end
  
      def notification_sent_today?(issue)
        log_file = File.join(Rails.root, 'plugins', 'redmine_issue_notifier', 'log', 'issue_notifier.log')
        today = Date.today
        count = 0
  
        File.open(log_file, 'r') do |file|
          file.each_line do |line|
            if line.include?("Notification sent for issue ##{issue.id}") &&
               line.include?(today.to_s)
              count += 1
            end
          end
        end
  
        count >= Setting.plugin_redmine_issue_notifier['max_notifications_per_day']
      end
  
      def log_notification(issue, message)
        log_file = File.join(Rails.root, 'plugins', 'redmine_issue_notifier', 'log', 'issue_notifier.log')
        File.open(log_file, 'a') do |file|
          file.puts("#{Time.now}: Issue ##{issue.id} - #{message}")
        end
      end
    end
  end
  