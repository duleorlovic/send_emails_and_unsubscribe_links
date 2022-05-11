# Unsubscribe links

When we send emails we need to provide an option for receiver to unsubscribe
from those email, aka unsubscribe links.
And of course, user does not need to log in to unsubscribe, but we want to make
sure that nobody can gues the unsubscribe link.

Let's start by adding a devise user and

You can use
https://api.rubyonrails.org/v5.2.2.1/classes/ActiveSupport/MessageVerifier.html
to encode strings or id
```
  @unsubscribe = Rails.application.message_verifier(:unsubscribe).generate(@user.id)
```

Old example

~~~
# app/views/layouts/_email_footer.html.erb
<p>
  <%= link_to "Unsubscribe", link_for_unsubscribe(user, controller.mapping_to_unsubscribe_group(controller.action_name)) %> from this type of email.
</p>
<p>
  <%= link_to "Manage", settings_user_url(user) %> which emails you receive.
</p>

# app/controllers/application_mail.rb
  def mapping_to_unsubscribe_group method_name
    group = ApplicationHelper::UNSUBSCRIBE_MAPPING_METHOD_TO_GROUP[method_name.to_s]
    if group.nil?
      puts "!!!!! No group found for method_name=#{method_name.to_s}"
      ExceptionNotifier.notify_exception(Exception.new("just to notify that there is no group for method_name #{method_name}") )
    end
    group
  end

# app/helpers/application_helper.rb
  UNSUBSCRIBE_MAPPING_METHOD_TO_GROUP = {
    "first_application_instructions" => "tips_and_help_emails_jobseeker",
    "application_in_review_instructions" => "tips_and_help_emails_jobseeker",
    "new_candidate_email" => "new_candidate_or_applicant",
    }
  def link_for_unsubscribe user, unsubscribe_group
    referral_token_and_unsubscribe_group = user.referral_token + unsubscribe_group.to_s
    unsubscribe_url key: Base64.encode64(referral_token_and_unsubscribe_group)
  end

# config/routes.rb
  get 'unsubscribe', to: 'welcome#unsubscribe'

# app/controllers/welome_controller.rb
  # GET /unsubscribe
  def unsubscribe
    referral_token_and_unsubscribe_group = Base64.decode64 params[:key] 
    referral_token = referral_token_and_unsubscribe_group[0..User::REFERRAL_TOKEN_LENGTH-1]
    @unsubscribe_group = referral_token_and_unsubscribe_group[User::REFERRAL_TOKEN_LENGTH..-1]
    if current_user
      if current_user.referral_token == referral_token
        @user = current_user
        @user.unsubscribe[ @unsubscribe_group] = "true"
        @user.save!
      else
        redirect_to root_path, alert: "This key is for different user, please log out"
      end
    else
      if @user = User.find_by( referral_token: referral_token)
        # we found the user
        @user.unsubscribe[ @unsubscribe_group] = "true"
        @user.save!
      else
        flash[:alert] = "Can't find user by this key. You need to signin in order to unsubscribe"
        redirect_to new_user_session_path and return
      end
    end
  end

# db/migrate/_add_unsubscribe_to_user.rb
class AddUnsubscribeToUser < ActiveRecord::Migration
  def change
    add_column :users, :unsubscribe, :hstore, default: {}
  end
end
~~~
