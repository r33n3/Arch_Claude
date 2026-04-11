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

tmux new-session -d -s "$SESSION" -c "$REPO/.claude/worktrees/foundation"
tmux send-keys -t "$SESSION" "echo '=== FOUNDATION — run first, raise PR before onboarding goes deep ===' && claude" Enter

tmux split-window -h -t "$SESSION" -c "$REPO/.claude/worktrees/onboarding"
tmux send-keys -t "$SESSION" "echo '=== ONBOARDING — wait for foundation PR to merge, then: git fetch origin && git rebase origin/main ===' && claude" Enter

tmux select-pane -t "$SESSION:0.0"
tmux attach -t "$SESSION"
