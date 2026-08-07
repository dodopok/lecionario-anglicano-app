#!/usr/bin/env bash
#
# Moves the one version both stores are built from.
#
#   ./tool/version.sh                    what the stores will see now
#   ./tool/version.sh show --json        the same, for a script to read
#   ./tool/version.sh bump build         a new upload of the same version
#   ./tool/version.sh bump patch         1.0.0 -> 1.0.1, and a new build
#   ./tool/version.sh bump minor         1.0.0 -> 1.1.0, and a new build
#   ./tool/version.sh bump major         1.0.0 -> 2.0.0, and a new build
#   ./tool/version.sh set 1.2.0 [7]      an exact version, and optionally build
#
# pubspec.yaml holds `version: <name>+<build>` and Flutter hands both halves to
# each platform: on Android as versionName and versionCode, on iOS as
# CFBundleShortVersionString and CFBundleVersion. Neither android/ nor ios/
# carries its own copy — moving them apart is what leads to a build Play or App
# Store Connect refuses because its number did not go up.
#
# Both stores refuse an upload whose build number has been used before, and
# neither lets it go back down, which is why the build number is shared and
# only ever counts up: one number, every upload of either platform, no reuse.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
pubspec="$repo_root/pubspec.yaml"

usage() {
  sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

read_version() {
  local line
  line="$(grep -E '^version: ' "$pubspec" | head -1 | sed 's/^version: //')"

  if [[ ! "$line" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
    echo "pubspec.yaml has '$line', which is not <major>.<minor>.<patch>+<build>." >&2
    exit 1
  fi

  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  build="${BASH_REMATCH[4]}"
  name="$major.$minor.$patch"
}

write_version() {
  local next="$1+$2"

  # A new file rather than `sed -i`, whose spelling differs between the BSD sed
  # on the release machine and the GNU sed everywhere else.
  local temporary
  temporary="$(mktemp)"
  awk -v replacement="version: $next" '
    !done && /^version: / { print replacement; done = 1; next }
    { print }
  ' "$pubspec" > "$temporary"
  mv "$temporary" "$pubspec"

  echo "pubspec.yaml  $name+$build  ->  $next"
  echo
  report "$1" "$2"
}

report() {
  local version="$1" number="$2"

  printf '  %-8s %-34s %s\n' 'Android' "versionName $version" \
    "versionCode $number"
  printf '  %-8s %-34s %s\n' 'iOS' "CFBundleShortVersionString $version" \
    "CFBundleVersion $number"
}

report_json() {
  printf '{"name":"%s","build":%s,"version":"%s+%s"}\n' \
    "$name" "$build" "$name" "$build"
}

command="${1:-show}"

case "$command" in
  show)
    read_version
    if [[ "${2:-}" == "--json" ]]; then
      report_json
      exit 0
    fi
    echo "pubspec.yaml  $name+$build"
    echo
    report "$name" "$build"
    ;;

  bump)
    read_version
    case "${2:-}" in
      major) write_version "$((major + 1)).0.0" "$((build + 1))" ;;
      minor) write_version "$major.$((minor + 1)).0" "$((build + 1))" ;;
      patch) write_version "$major.$minor.$((patch + 1))" "$((build + 1))" ;;
      # A resubmission of the same version — a rejected build, or a store
      # listing fix that still needs a fresh binary.
      build) write_version "$name" "$((build + 1))" ;;
      *)
        echo "Bump what? major, minor, patch or build." >&2
        exit 1
        ;;
    esac
    ;;

  set)
    read_version
    next_name="${2:-}"
    if [[ ! "$next_name" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Give a version as <major>.<minor>.<patch>, for example 1.2.0." >&2
      exit 1
    fi

    next_build="${3:-$((build + 1))}"
    if [[ ! "$next_build" =~ ^[0-9]+$ ]]; then
      echo "The build number is a whole number, not '$next_build'." >&2
      exit 1
    fi
    if (( next_build <= build )); then
      echo "Build $next_build has been used already: pubspec.yaml is at $build," >&2
      echo "and neither store accepts an upload that does not count up." >&2
      exit 1
    fi

    write_version "$next_name" "$next_build"
    ;;

  -h|--help|help)
    usage
    ;;

  *)
    echo "Unknown command: $command" >&2
    echo >&2
    usage >&2
    exit 1
    ;;
esac
