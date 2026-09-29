#!/bin/sh
# One-shot job that runs before Mastodon starts: prepares the database and, on the
# first start, creates the owner account.
set -e

. /umbrel-scripts/env.sh

if [ ! -s /umbrel-config/vapid.env ]; then
  echo "Generating web push keys..."
  bundle exec rails mastodon:webpush:generate_vapid_key | grep '^VAPID_' > /umbrel-config/vapid.env.new
  mv /umbrel-config/vapid.env.new /umbrel-config/vapid.env
  . /umbrel-scripts/env.sh
fi

echo "Preparing database..."
bundle exec rails db:prepare
bundle exec rails db:seed

bundle exec rails runner /umbrel-scripts/create-owner.rb
