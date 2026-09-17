#!/usr/bin/env bash
# Create or update a GitHub release and upload assets with per-call retries.
# action-gh-release fails the whole step on one transient API error after
# uploading hundreds of MB; doing it with gh lets each call be retried on
# its own and reruns safely (--clobber).
#
# Usage: gh-release.sh <tag> <name> <notes-file> [flags] <path>...
#   flags: --prerelease      mark the release as a prerelease
#          --generate-notes  append GitHub generated release notes to the body
#   paths: files upload as-is, directories upload every file inside
set -euo pipefail

TAG="${1:?usage: gh-release.sh <tag> <name> <notes-file> [flags] <path>...}"
NAME="${2:?usage: gh-release.sh <tag> <name> <notes-file> [flags] <path>...}"
NOTES_FILE="${3:?usage: gh-release.sh <tag> <name> <notes-file> [flags] <path>...}"
shift 3

PRERELEASE=false
GENERATE_NOTES=false
PATHS=()
for arg in "$@"; do
  case "$arg" in
    --prerelease) PRERELEASE=true ;;
    --generate-notes) GENERATE_NOTES=true ;;
    *) PATHS+=("$arg") ;;
  esac
done
[ "${#PATHS[@]}" -gt 0 ] || { echo "gh-release: no assets given" >&2; exit 1; }

REPO="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is not set}"

retry() {
  local attempt
  for attempt in 1 2 3; do
    "$@" && return 0
    echo "gh-release: attempt $attempt failed: $*" >&2
    sleep 15
  done
  return 1
}

BODY="$(mktemp)"
trap 'rm -f "$BODY"' EXIT
cat "$NOTES_FILE" > "$BODY"
if [ "$GENERATE_NOTES" = "true" ]; then
  GENERATED=$(gh api -X POST "repos/$REPO/releases/generate-notes" -f tag_name="$TAG" -q .body 2>/dev/null || true)
  [ -n "$GENERATED" ] && printf '\n%s\n' "$GENERATED" >> "$BODY"
fi

EDIT_ARGS=(--title "$NAME" --notes-file "$BODY")
[ "$PRERELEASE" = "true" ] && EDIT_ARGS+=(--prerelease)

if gh release view "$TAG" -R "$REPO" >/dev/null 2>&1; then
  retry gh release edit "$TAG" -R "$REPO" "${EDIT_ARGS[@]}"
else
  retry gh release create "$TAG" -R "$REPO" "${EDIT_ARGS[@]}" --latest=false
fi

for path in "${PATHS[@]}"; do
  if [ -d "$path" ]; then
    for f in "$path"/*; do
      [ -f "$f" ] && retry gh release upload "$TAG" "$f" --clobber -R "$REPO"
    done
  elif [ -f "$path" ]; then
    retry gh release upload "$TAG" "$path" --clobber -R "$REPO"
  fi
done

echo "gh-release: $TAG done"
