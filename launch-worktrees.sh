#!/usr/bin/env bash
# Run from repo root: cd /path/to/repo && ./launch-worktrees.sh
# Tmux navigation: Ctrl+B + arrow keys to switch panes | Ctrl+B q to jump by number
# When agents finish: check sprint-progress.md, then merge PRs in order from main session
# Do NOT direct-merge from worktree panes — coordinate from the main session
#
# SPRINT 1 — Sequential launch (foundation must complete before onboarding goes deep)
# Step 1: foundation agent runs alone first
# Step 2: once foundation PR is merged, pull main in onboarding pane and continue

SESSION="worktrees"
REPO="$(pwd)"

FOUNDATION_PROMPT="Read CLAUDE-foundation.md and execute the task fully. Build all files described, validate the first-time and returning student flows work, then raise a PR and update sprint-progress.md."

ONBOARDING_PROMPT="Read CLAUDE-onboarding.md. Wait for the foundation PR to merge first (git fetch origin && git rebase origin/main), then execute the task fully. Build day-0-onboarding.md and opening-exercise.md, validate end-to-end under at least 2 personas, then raise a PR and update sprint-progress.md."

tmux new-session -d -s "$SESSION" -c "$REPO/.claude/worktrees/foundation"
tmux send-keys -t "$SESSION" "claude --dangerously-skip-permissions -p \"$FOUNDATION_PROMPT\"" Enter

tmux split-window -h -t "$SESSION" -c "$REPO/.claude/worktrees/onboarding"
tmux send-keys -t "$SESSION" "claude --dangerously-skip-permissions -p \"$ONBOARDING_PROMPT\"" Enter

tmux select-pane -t "$SESSION:0.0"
tmux attach -t "$SESSION"
