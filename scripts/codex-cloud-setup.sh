#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

flutter_version="${FLUTTER_VERSION:-3.44.0}"
flutter_sdk_dir="${FLUTTER_SDK_DIR:-$HOME/.local/flutter-$flutter_version}"

run() {
  printf '\n==> %s\n' "$*"
  "$@"
}

persist_flutter_path() {
  local export_line="export PATH=\"$flutter_sdk_dir/bin:\$PATH\""

  mkdir -p "$HOME/.local/bin"
  for profile in "$HOME/.bashrc" "$HOME/.profile"; do
    touch "$profile"
    if ! grep -Fqx "$export_line" "$profile"; then
      printf '\n%s\n' "$export_line" >> "$profile"
    fi
  done
}

flutter_matches_expected_version() {
  command -v flutter >/dev/null 2>&1 || return 1
  flutter --version 2>/dev/null | head -n 1 | grep -Fq "Flutter $flutter_version"
}

ensure_flutter() {
  if flutter_matches_expected_version; then
    return
  fi

  if [[ -x "$flutter_sdk_dir/bin/flutter" ]]; then
    export PATH="$flutter_sdk_dir/bin:$PATH"
    if flutter_matches_expected_version; then
      persist_flutter_path
      return
    fi
  fi

  if [[ -e "$flutter_sdk_dir" ]]; then
    printf 'Expected Flutter %s, but %s already exists and does not match.\n' "$flutter_version" "$flutter_sdk_dir" >&2
    printf 'Reset the Codex environment cache or set FLUTTER_SDK_DIR to a clean path.\n' >&2
    exit 1
  fi

  run git clone --depth 1 --branch "$flutter_version" https://github.com/flutter/flutter.git "$flutter_sdk_dir"
  export PATH="$flutter_sdk_dir/bin:$PATH"
  persist_flutter_path
}

ensure_env_file() {
  if [[ -f .env ]]; then
    return
  fi

  if [[ -f .env.example ]]; then
    cp .env.example .env
  else
    touch .env
  fi
}

ensure_flutter
ensure_env_file

run flutter --version
run dart --version
run flutter config --no-analytics
run dart --disable-analytics

run flutter pub get --enforce-lockfile
run flutter gen-l10n
run dart run build_runner build --delete-conflicting-outputs

(
  cd widgetbook
  run dart run build_runner build --delete-conflicting-outputs
)
