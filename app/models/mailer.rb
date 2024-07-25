class Mailer < ActionMailer::Base
    def issue_notification(issue)
      @issue = issue
      cc_recipients = Setting.plugin_redmine_issue_notifier['cc'].split(',').map(&:strip)
      subject_prefix = Setting.plugin_redmine_issue_notifier['subject_prefix']
      custom_field_id = Setting.plugin_redmine_issue_notifier['custom_field_id']
      custom_emails = fetch_custom_field_emails(issue, custom_field_id)
      
      mail(
        to: custom_emails,
        cc: cc_recipients,
        subject: "#{subject_prefix} Issue ##{issue.id} is due in 5 days",
        body: "The issue ##{issue.id} with subject '#{issue.subject}' is due in 5 days."
      )
    end
  
    private
  
    def fetch_custom_field_emails(issue, custom_field_id)
      return [] if custom_field_id.blank?
  
      custom_field = issue.custom_field_values.detect { |cf| cf.custom_field.id == custom_field_id.to_i }
      custom_field ? custom_field.value.split(',').map(&:strip) : []
    end
  end
  