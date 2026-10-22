-- Yazi plugin bootstrap.
--
-- Plugins are installed with `ya pkg add` and the set is declared in
-- bin/install-packages, so a new machine reproduces it.
--
-- Note on sourcing: the first two are first-party (yazi-rs/plugins); the rest
-- are third-party. The yazi docs warn third-party plugins generally only
-- guarantee compatibility with yazi HEAD, while this box tracks the Homebrew
-- release — so those are the ones to suspect first after a yazi upgrade.

-- A plugin that is too new for the installed yazi must not take the whole
-- config down with it. `ya pkg add` resolves against yazi HEAD, so a machine on
-- a packaged release can end up with a plugin it cannot load — and a bare
-- `require` failure aborts init.lua entirely, leaving yazi unusable rather than
-- merely less featureful.
--
-- Seen 2026-08-29 on the Nobara box: git.yazi wanted Yazi >= 26.8.15 against an
-- installed 26.5.6 (dnf/COPR), and yazi refused to start at all. The macOS side
-- never saw it because Homebrew tracks a newer release. The real fix is to
-- upgrade yazi on Linux; this makes the failure survivable in the meantime, and
-- on any future version skew.
local function use(name, fn)
    local ok, mod = pcall(require, name)
    if not ok then
        -- Deliberately quiet: yazi has no startup log, and an error() here would
        -- reintroduce exactly the failure this guards against.
        return
    end
    if fn then pcall(fn, mod) end
end

-- git.yazi — git status as a linemode on the right of each row.
-- Read-only: it shells out to `git status` and never mutates, so it is safe in
-- the colocated jj repos where mutating git commands are off-limits. Verified
-- against ~/Repos/dotfiles, where `git status` reports the @ changes.
use("git", function(m) m:setup { order = 1500 } end)

-- full-border.yazi — draw a border around parent/current/preview.
use("full-border", function(m) m:setup { type = ui.Border.ROUNDED } end)

-- starship.yazi — render the starship prompt as yazi's header, so the path
-- reads the same here as in the shell. Uses the existing ~/.config/starship.toml.
use("starship", function(m) m:setup() end)

-- pref-by-location.yazi — remember sort order / linemode / hidden-file state
-- per directory. The setup call is required even with no options set.
use("pref-by-location", function(m) m:setup {} end)
