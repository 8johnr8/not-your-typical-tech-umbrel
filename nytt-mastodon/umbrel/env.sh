# Sourced by the Mastodon containers before they start. Secrets are derived from the
# Umbrel app seed, so they are stable across restarts and never have to be typed in.

derive() {
  printf '%s' "${APP_SEED}:$1" | sha256sum | cut -c1-64
}

export SECRET_KEY_BASE="$(derive secret-key-base)$(derive secret-key-base-2)"
export ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY="$(derive active-record-deterministic-key)"
export ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT="$(derive active-record-key-derivation-salt)"
export ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY="$(derive active-record-primary-key)"

# Web push keys must be a real EC key pair, so they are generated once by setup.sh.
if [ -s /umbrel-config/vapid.env ]; then
  set -a
  . /umbrel-config/vapid.env
  set +a
fi
