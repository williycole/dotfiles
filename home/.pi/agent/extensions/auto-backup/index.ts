import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface BackupState {
  enabled: boolean;
  lastCommitHash: string;
  lastPrompt: string;
  turnCounter: number;
}

async function getGitDir(): Promise<string | null> {
  try {
    const { exec } = await import("node:child_process");
    const { promisify } = await import("node:util");
    const execAsync = promisify(exec);
    const agentDir = join(process.env.HOME || "", ".pi/agent");
    // Verify it's a git repo
    await execAsync("git rev-parse --git-dir", { cwd: agentDir });
    return agentDir;
  } catch {
    return null;
  }
}

// Only stage meaningful changes — skip noisy session logs and crash files
const STAGE_PATHS = [
  "extensions/",
  "skills/",
  "themes/",
  "settings.json",
  "auth.json",
  "AGENTS.md",
];

async function commitWithMessage(message: string, agentDir: string): Promise<string | null> {
  try {
    const { exec } = await import("node:child_process");
    const { promisify } = await import("node:util");
    const execAsync = promisify(exec);

    // Stage only the paths we care about
    for (const p of STAGE_PATHS) {
      // Don't fail if a path doesn't exist (e.g., auth.json may be absent)
      await execAsync(`git add --all -- ${p}`, { cwd: agentDir }).catch(() => {});
    }

    // Check if there are staged changes to commit
    const { stdout: staged } = await execAsync("git diff --cached --name-only", { cwd: agentDir });
    if (!staged.trim()) {
      return null; // No meaningful changes
    }

    // Commit with the message
    const safeMessage = message.replace(/"/g, '\\"').substring(0, 200);
    const { stdout } = await execAsync(
      `git commit -m "${safeMessage}"`,
      { cwd: agentDir }
    );

    // Get the hash
    const { stdout: hash } = await execAsync("git rev-parse HEAD", { cwd: agentDir });
    return hash.trim();
  } catch (error) {
    console.error("[auto-backup] Commit failed:", error);
    return null;
  }
}

import { join } from "node:path";

export default async function autoBackup(pi: ExtensionAPI) {
  const state: BackupState = {
    enabled: true,
    lastCommitHash: "",
    lastPrompt: "",
    turnCounter: 0,
  };

  const agentDir = await getGitDir();
  if (!agentDir) {
    console.log("[auto-backup] No git repo found, extension disabled");
    return;
  }

  // Get current commit hash
  try {
    const { exec } = await import("node:child_process");
    const { promisify } = await import("node:util");
    const execAsync = promisify(exec);
    const { stdout } = await execAsync("git rev-parse HEAD", { cwd: agentDir });
    state.lastCommitHash = stdout.trim();
  } catch {
    // No commits yet
  }

  // Capture the prompt when agent starts
  pi.on("agent_start", async (event) => {
    if (!state.enabled) return;
    // Store the prompt for the commit message
    const prompt = event.prompt || "Unknown task";
    state.lastPrompt = prompt.substring(0, 100);
  });

  // Commit after each turn completes
  pi.on("agent_end", async (_event, ctx) => {
    if (!state.enabled) return;

    state.turnCounter++;

    // Commit with the prompt as message
    const commitMessage = `Task #${state.turnCounter}: ${state.lastPrompt}`;
    const hash = await commitWithMessage(commitMessage, agentDir);

    if (hash) {
      state.lastCommitHash = hash;
      ctx.ui.notify(`[auto-backup] Saved: Task #${state.turnCounter}`, "success");
    }
  });

  // Commit on session shutdown
  pi.on("session_shutdown", async () => {
    if (!state.enabled) return;
    const message = `Session end after ${state.turnCounter} task(s)`;
    await commitWithMessage(message, agentDir);
  });

  // Manual commands

  pi.registerCommand("backup", {
    description: "Create a manual backup checkpoint",
    async handler(_args, ctx) {
      const hash = await commitWithMessage(`Manual checkpoint: ${state.lastPrompt || "unsaved work"}`, agentDir);
      if (hash) {
        state.lastCommitHash = hash;
        ctx.ui.notify(`[auto-backup] Checkpoint created`, "success");
      } else {
        ctx.ui.notify("[auto-backup] Nothing to commit", "info");
      }
    },
  });

  pi.registerCommand("backup:toggle", {
    description: "Toggle auto-backup on/off",
    async handler(_args, ctx) {
      state.enabled = !state.enabled;
      ctx.ui.notify(`[auto-backup] ${state.enabled ? "Enabled" : "Disabled"}`, state.enabled ? "success" : "info");
    },
  });

  pi.registerCommand("backup:log", {
    description: "Show recent backup commits",
    async handler(_args, ctx) {
      try {
        const { exec } = await import("node:child_process");
        const { promisify } = await import("node:util");
        const execAsync = promisify(exec);

        const { stdout } = await execAsync("git log --oneline -10", { cwd: agentDir });
        const lines = stdout.trim().split("\n").filter(Boolean);

        if (lines.length === 0) {
          ctx.ui.notify("No backups yet", "info");
          return;
        }

        ctx.ui.notify(
          `Recent tasks:\n${lines.map((l) => `  ${l}`).join("\n")}`,
          "info"
        );
      } catch {
        ctx.ui.notify("Could not read backup history", "error");
      }
    },
  });

  pi.registerCommand("backup:restore", {
    description: "Restore to a previous task (interactive)",
    async handler(_args, ctx) {
      try {
        const { exec } = await import("node:child_process");
        const { promisify } = await import("node:util");
        const execAsync = promisify(exec);

        // Get recent commits
        const { stdout } = await execAsync("git log --oneline -10", { cwd: agentDir });
        const commits = stdout.trim().split("\n").filter(Boolean);

        if (commits.length === 0) {
          ctx.ui.notify("No commits to restore from", "error");
          return;
        }

        const options = commits.map((c) => c.substring(0, 60));
        const selected = await ctx.ui.select("Restore to which task?", options);

        if (!selected) return;

        const hash = selected.split(" ")[0];

        // Commit current state first
        const currentTask = state.lastPrompt ? `before restore to task ${hash}` : "before restore";
        await commitWithMessage(currentTask, agentDir);

        // Reset to selected commit
        await execAsync(`git reset --hard ${hash}`, { cwd: agentDir });

        state.lastCommitHash = hash;

        // Update turn counter based on restored state
        const { stdout: count } = await execAsync("git rev-list --count HEAD", { cwd: agentDir });
        state.turnCounter = parseInt(count.trim(), 10) || 0;

        ctx.ui.notify(`[auto-backup] Restored to: ${selected.substring(0, 50)}`, "success");

        // Reload extensions to pick up restored code
        await ctx.reload();
      } catch (error) {
        ctx.ui.notify(`[auto-backup] Restore failed: ${error}`, "error");
      }
    },
  });

  pi.registerCommand("backup:status", {
    description: "Show current backup status",
    async handler(_args, ctx) {
      const status = state.enabled ? "Enabled" : "Disabled";
      const hash = state.lastCommitHash ? state.lastCommitHash.substring(0, 8) : "none";
      ctx.ui.notify(`[auto-backup]\nStatus: ${status}\nTasks completed: ${state.turnCounter}\nLast commit: ${hash}`, "info");
    },
  });

  console.log("[auto-backup] Extension loaded (task-based mode)");
}