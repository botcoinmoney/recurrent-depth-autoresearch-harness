#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage: checkpoint_commit_push.sh [--message TEXT] [--remote NAME] [--dry-run] [--no-push]

Commit all current changes in the active git repository and push them.

Options:
  --message TEXT  Commit message to use. Defaults to a UTC checkpoint timestamp.
  --remote NAME   Remote to push to. Defaults to origin.
  --dry-run       Show what would happen without committing or pushing.
  --no-push       Create the checkpoint commit but skip the push.
  -h, --help      Show this help text.
EOF
}

message=""
remote="origin"
dry_run=0
do_push=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --message)
      if [[ $# -lt 2 ]]; then
        echo "missing value for --message" >&2
        exit 1
      fi
      message="$2"
      shift 2
      ;;
    --remote)
      if [[ $# -lt 2 ]]; then
        echo "missing value for --remote" >&2
        exit 1
      fi
      remote="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --no-push)
      do_push=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not inside a git repository" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
branch="$(git branch --show-current)"
if [[ -z "$branch" ]]; then
  echo "refusing to checkpoint a detached HEAD; checkout a branch first" >&2
  exit 1
fi

if [[ -z "$message" ]]; then
  message="Checkpoint: $(date -u +%Y-%m-%dT%H:%MZ)"
fi

echo "repo: ${repo_root}"
echo "branch: ${branch}"
echo "remote: ${remote}"
echo "message: ${message}"

if [[ $dry_run -eq 1 ]]; then
  echo "dry-run: showing git status only"
  git status --short
  exit 0
fi

git add -A

if git diff --cached --quiet; then
  echo "no changes to checkpoint"
  exit 0
fi

git commit -m "$message"

if [[ $do_push -eq 1 ]]; then
  if git remote get-url "$remote" >/dev/null 2>&1; then
    git push -u "$remote" "$branch"
  else
    echo "remote not found: ${remote}" >&2
    exit 1
  fi
fi

if [[ $do_push -eq 1 ]]; then
  echo "checkpoint committed and pushed: $(git rev-parse --short HEAD)"
else
  echo "checkpoint committed: $(git rev-parse --short HEAD)"
fi
