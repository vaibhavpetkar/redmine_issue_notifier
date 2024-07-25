 
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
  