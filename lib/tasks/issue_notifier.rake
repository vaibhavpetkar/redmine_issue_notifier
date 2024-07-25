 
namespace :issue_notifier do
    desc "Send notifications for issues with 5 days remaining to due date"
    task :send_notifications => :environment do
      settings = Setting.plugin_redmine_issue_notifier
      send_time = settings['send_time']
      current_time = Time.now.strftime("%H:%M")
  
      if current_time == send_time
        issues = Issue.where("due_date = ?", 5.days.from_now.to_date)
        issues.each do |issue|
          send_notification(issue)
        end
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
      today = Date.today
      count = IssueNotifierLog.where(issue: issue, created_at: today.beginning_of_day..today.end_of_day).count
      count >= Setting.plugin_redmine_issue_notifier['max_notifications_per_day']
    end
  
    def log_notification(issue, message)
      IssueNotifierLog.create(issue: issue, message: message)
    end
  end
  