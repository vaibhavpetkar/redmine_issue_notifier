require 'redmine'

Redmine::Plugin.register :redmine_issue_notifier do
  name 'Redmine Issue Notifier plugin'
  author 'Vaibhav Petkar'
  description 'This plugin sends email notifications for issues with 5 days remaining to the end date'
  version '0.0.1'
  requires_redmine :version_or_higher => '4.0.0'

  settings(
    default: {
      'cc' => 'cc@example.com',
      'subject_prefix' => '[Redmine]',
      'send_time' => '11:00',
      'max_notifications_per_day' => 5,
      'custom_field_id' => nil
    },
    partial: 'settings/issue_notifier_settings'
  )
end

require_relative 'lib/issue_notifier_hook'
