// Meta+Ctrl+<digit> -> send the active window to that virtual desktop.
//
// WHY META+CTRL AND NOT META+SHIFT. Meta+Shift+<digit> cannot be grabbed on
// this machine, by any mechanism. Exhausted 2026-08-17:
//   - kglobalshortcutsrc on Plasma's own "Window to Desktop N"  -> no grab
//   - same, with the shifted symbols (Meta+Shift+#)             -> no grab
//   - same, after wiping all 25 entries so KWin re-registered   -> no grab
//   - registerShortcut from a KWin script, digit form           -> no grab
//   - registerShortcut from a KWin script, BOTH forms at once   -> no grab
// Every one of those reported success everywhere it could be inspected:
// System Settings showed the binding, kglobalaccel returned it live with the
// right keycode. Pressing the key emitted no globalShortcutPressed signal at
// all, so the grab never existed.
//
// The common factor is the SHIFTED NUMBER ROW. Shift+3 emits `numbersign`, not
// `3` (xkbcli dump-keymap-wayland). Meta+Shift+<letter> works fine here -
// Krohnkite's Meta+Shift+F and Meta+Shift+T both fire - because Shift does not
// change a letter's keysym. Ctrl does not change any keysym, so Meta+Ctrl+3
// stays Meta+Ctrl+3 and sidesteps the whole problem.
//
// Meta+Ctrl is known to grab here: Krohnkite's Meta+Ctrl+H/J/K/L resize keys
// work. The switch direction (Meta+<digit>) needs no help; Plasma's own
// "Switch to Desktop N" binds fine. Only the move direction was ever broken.
//
// Reload after editing WITHOUT a logout:
//   gdbus call --session --dest org.kde.KWin --object-path /Scripting \
//     --method org.kde.kwin.Scripting.unloadScript move-to-desktop
//   ... .loadScript <path-to-this-file> move-to-desktop ; ... .start

function moveTo(n, follow) {
    return function () {
        var w = workspace.activeWindow;
        if (!w) return;
        var desktops = workspace.desktops;
        if (n > desktops.length) return;
        w.desktops = [desktops[n - 1]];
        // The prior Hyprland setup bound SUPER SHIFT to `movetoworkspace`,
        // which FOLLOWS the window, and SUPER SHIFT ALT to
        // `movetoworkspacesilent`, which stays put. Both behaviours are kept so
        // the muscle memory carries over.
        if (follow) workspace.currentDesktop = desktops[n - 1];
    };
}

for (var i = 1; i <= 10; i++) {
    (function (n) {
        var digit = n === 10 ? "0" : String(n);
        registerShortcut("MoveWinToDeskF" + n, "Move Window to Desktop " + n,
                         "Meta+Ctrl+" + digit, moveTo(n, true));
        registerShortcut("MoveWinToDeskS" + n,
                         "Move Window to Desktop " + n + " (stay)",
                         "Meta+Ctrl+Alt+" + digit, moveTo(n, false));
    })(i);
}
