# frozen_string_literal: true

# Creates the Owner account the first time Mastodon starts on Umbrel. Runs through
# `rails runner`, mirroring what `tootctl accounts create --role Owner --confirmed` does.

username = ENV.fetch('OWNER_USERNAME', '').strip
email = ENV.fetch('OWNER_EMAIL', '').strip
password = ENV.fetch('OWNER_PASSWORD', '')

owner_role = UserRole.find_by(name: 'Owner')

if owner_role.nil?
  warn 'Owner account: the Owner role does not exist yet, skipping.'
  exit 0
end

if User.exists?(role_id: owner_role.id)
  puts 'Owner account already exists.'
  exit 0
end

if username.empty? || email.empty? || password.empty?
  puts 'Owner account: OWNER_USERNAME or OWNER_EMAIL is empty, skipping.'
  exit 0
end

if Account.find_local(username) || User.exists?(email: email)
  warn "Owner account: @#{username} or #{email} is already taken, skipping."
  exit 0
end

# The default e-mail address uses the Umbrel's .local name, which has no MX record.
User.define_singleton_method(:skip_mx_check?) { true }

user = User.new(
  email: email,
  password: password,
  agreement: true,
  role_id: owner_role.id,
  confirmed_at: Time.now.utc,
  bypass_registration_checks: true,
  account: Account.new(username: username)
)

if user.save
  user.confirmed_at = nil
  user.mark_email_as_confirmed!
  user.approve! unless user.approved?
  puts "Owner account @#{username} (#{email}) created."
else
  warn "Owner account could not be created: #{user.errors.full_messages.join(', ')}"
end
