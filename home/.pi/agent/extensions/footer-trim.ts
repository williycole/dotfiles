/**
 * Minimal pi footer: context budget + model.
 * Run timer only while agent is working; everything else is /status material.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const DROP_KEYS = new Set(["caveman", "ponytail", "pi-lens-lsp"]);

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	return `${Math.round(count / 1000000)}M`;
}

function stripAnsi(text: string): string {
	return text.replace(/\x1b\[[0-9;]*m/g, "");
}

function shouldDropStatus(key: string, plain: string): boolean {
	if (DROP_KEYS.has(key)) return true;
	if (/LSP (Active|Inactive|Failed)/i.test(plain) || /^LSP:/.test(plain)) return true;
	return false;
}

function compactRunTimer(text: string): string | undefined {
	const plain = stripAnsi(text).trim();
	if (!plain || /\bidle\b/i.test(plain)) return undefined;
	const elapsed = plain.match(/run\s+(\d{1,2}:\d{2}(?::\d{2})?)/i);
	return elapsed ? `run ${elapsed[1]}` : undefined;
}

function installFooter(ctx: ExtensionContext): void {
	if (!ctx.hasUI) return;

	ctx.ui.setFooter((tui, theme, footerData) => {
		const unsub = footerData.onBranchChange?.(() => tui.requestRender());

		return {
			dispose: () => unsub?.(),
			invalidate() {},
			render(width: number): string[] {
				const usage = ctx.getContextUsage?.();
				const window = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
				const pct = usage?.percent != null ? `${usage.percent.toFixed(1)}%` : "?%";
				const segments = [`${pct}/${formatTokens(window)}`];

				for (const [key, raw] of [...footerData.getExtensionStatuses()].sort(([a], [b]) =>
					a.localeCompare(b),
				)) {
					const plain = stripAnsi(raw).trim();
					if (!plain || shouldDropStatus(key, plain)) continue;

					if (key === "run-timer") {
						const run = compactRunTimer(raw);
						if (run) segments.push(run);
					}
				}

				const model = ctx.model?.id ?? "no-model";
				const thinking =
					ctx.model?.reasoning && ctx.thinkingLevel && ctx.thinkingLevel !== "off"
						? ` • ${ctx.thinkingLevel}`
						: "";
				const right = `${model}${thinking}`;

				const left = theme.fg("dim", segments.join(" | "));
				const pad = Math.max(1, width - visibleWidth(left) - visibleWidth(theme.fg("dim", right)));
				return [truncateToWidth(left + " ".repeat(pad) + theme.fg("dim", right), width)];
			},
		};
	});
}

export default function footerTrim(pi: ExtensionAPI) {
	let liveCtx: ExtensionContext | undefined;

	const applyFooter = (ctx: ExtensionContext) => {
		liveCtx = ctx;
		// Run after other extensions' session_start handlers.
		queueMicrotask(() => {
			if (liveCtx === ctx) installFooter(ctx);
		});
	};

	pi.on("session_start", (_event, ctx) => applyFooter(ctx));
	pi.on("session_tree", (_event, ctx) => applyFooter(ctx));

	for (const event of ["agent_start", "agent_end", "agent_settled"] as const) {
		pi.on(event, (_e, ctx) => {
			liveCtx = ctx;
		});
	}

	pi.on("session_shutdown", (_event, ctx) => {
		liveCtx = undefined;
		ctx.ui?.setFooter?.(undefined);
	});
}
