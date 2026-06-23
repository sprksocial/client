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

flutter_matches_expected_version() {
  command -v flutter >/dev/null 2>&1 || return 1
  flutter --version 2>/dev/null | head -n 1 | grep -Fq "Flutter $flutter_version"
}

ensure_flutter_from_cache() {
  if [[ -x "$flutter_sdk_dir/bin/flutter" ]]; then
    export PATH="$flutter_sdk_dir/bin:$PATH"
  fi

  if flutter_matches_expected_version; then
    return
  fi

  printf 'Flutter %s is not available in this cached container.\n' "$flutter_version" >&2
  printf 'Reset the Codex environment cache so the setup script can reinstall it.\n' >&2
  exit 1
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

ensure_flutter_from_cache
ensure_env_file

run flutter --version
run flutter pub get --enforce-lockfile
run flutter gen-l10n
run dart run build_runner build --delete-conflicting-outputs

(
  cd widgetbook
  run dart run build_runner build --delete-conflicting-outputs
)
