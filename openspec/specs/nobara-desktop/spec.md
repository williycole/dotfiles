# nobara-desktop Specification

## Purpose

The Plasma desktop these boxes actually run.

Ten virtual desktops, auto-tiling through krohnkite, and launcher entries for the
controls the owner uses often enough that typing them would mean not using them.

The awkward part this capability exists to record: kglobalaccel reads a desktop
file's shortcut only when it registers a component for the FIRST time, so a stale
`_launch` entry shadows the file permanently and every later edit is read by
nothing. Five attempts failed before that was understood.
## Requirements
### Requirement: Stock Nobara KDE Plasma is the only desktop

The system SHALL use the KDE Plasma desktop that Nobara already ships as the sole desktop on every machine. No second desktop, compositor, or session SHALL be installed alongside it. The desktop SHALL come from Nobara's own repositories so it updates with the rest of the system, and SHALL NOT depend on a third-party COPR, a pinned external checkout, or an installer script.

The owner-facing behaviour the desktop SHALL provide is: a keyboard-driven launcher, automatic tiling, fully rebindable shortcut keys, and per-screen virtual desktops. Coordinated cross-application theming is explicitly NOT required and SHALL NOT be a reason to add a second desktop.

#### Scenario: Only one desktop session is installed

- **WHEN** the machine finishes provisioning
- **THEN** exactly one desktop session SHALL be offered at login
- **AND** no Hyprland, Omadora, or other compositor session SHALL be present

#### Scenario: Desktop updates with the system

- **WHEN** a normal system update runs
- **THEN** the desktop SHALL update as part of it
- **AND** no separate audit, pin, or third-party repository step SHALL be required to keep it current

#### Scenario: The four owner-facing behaviours are present

- **WHEN** the owner logs in
- **THEN** a launcher, automatic tiling, rebindable shortcuts, and per-screen virtual desktops SHALL all be available and bound

### Requirement: Tiling can be turned off from the keyboard

Automatic tiling SHALL be switchable off and back on from the keyboard, without opening settings, so that a full-screen game, a video, or any application that fights a tiler can be given a plain floating desktop.

The switch SHALL apply to the current virtual desktop only, leaving the others tiled, and its effect SHALL be immediately visible in the arrangement of windows rather than requiring the owner to remember a hidden state.

Turning tiling off SHALL NOT be implemented by unloading, disabling, or otherwise toggling the tiling component itself, because doing so is documented by the tiler as leaving multiple instances running.

#### Scenario: Owner turns tiling off for the current desktop

- **WHEN** the owner presses the tiling-off shortcut on a tiled desktop
- **THEN** windows on that desktop SHALL become freely floating and stay where they are put
- **AND** other virtual desktops SHALL remain tiled

#### Scenario: Owner turns tiling back on

- **WHEN** the owner presses the tiling-on shortcut on a floating desktop
- **THEN** windows on that desktop SHALL be tiled again

#### Scenario: A single window needs to float on a tiled desktop

- **WHEN** the owner floats the focused window
- **THEN** that window SHALL float while the remaining windows on the desktop stay tiled

### Requirement: Polkit agent for the lock's prompts

The desktop SHALL provide a running polkit authentication agent, so that polkit authorization dialogs appear for the owner

The provisioning self-test SHALL confirm that a real authentication dialog appears, not merely that an agent process exists, because the failure mode this guards against is a gated action failing silently for want of an agent.

#### Scenario: Polkit prompt appears in the desktop session

- **WHEN** the user triggers a polkit-gated action
- **THEN** a polkit authentication dialog SHALL appear
- **AND** the action SHALL NOT silently fail for want of an agent

### Requirement: Desktop configuration lives in the dotfiles

The desktop's owner-facing configuration — shortcut bindings, virtual-desktop count, tiling script settings, display layout — SHALL be declared in the dotfiles and linked into `$HOME`. No external project SHALL be relied on to supply base configuration on the machine.

Linux gating SHALL be structural, not conditional: desktop configuration SHALL live under `os/linux/`, which is linked only when `uname` says Linux, so it cannot reach a non-Linux machine at all.

#### Scenario: A rebuilt machine gets the same desktop configuration

- **WHEN** a machine is rebuilt and the dotfiles are applied
- **THEN** shortcuts, virtual desktops, tiling behaviour, and display layout SHALL match the previous machine without any manual reconfiguration

#### Scenario: Linux-only desktop configuration cannot render elsewhere

- **WHEN** desktop configuration is added — `.desktop` launchers, systemd user environment, compositor config
- **THEN** it SHALL be placed under `os/linux/`, never under `home/`
- **AND** this SHALL be checkable by looking at the file's path in the repo on any machine, with no tool run and no comparison against the other machine

### Requirement: Pocket 4 rotation is a device property, not a desktop feature

On the Pocket 4, screen rotation SHALL be corrected at the device layer so that the orientation reported by the system sensor service is true for the hardware. The correction SHALL be a system-level hardware database property, applied before any desktop starts, so that any desktop reads the correct orientation without a helper process. Touchscreen coordinate rotation SHALL likewise be a device-level input property.

The system SHALL NOT depend on a per-compositor rotation daemon. Rotation SHALL survive a change of desktop, theme, or session.

#### Scenario: Sensor reports true orientation

- **WHEN** the device is held in each of its four rotations
- **THEN** the system sensor service SHALL report the orientation matching the device's physical position

#### Scenario: Rotation works without a helper process

- **WHEN** the owner rotates the device
- **THEN** the display and touchscreen SHALL rotate together
- **AND** no compositor-specific rotation daemon SHALL be running

#### Scenario: Rotation survives a desktop or theme change

- **WHEN** the desktop or theme is changed
- **THEN** rotation SHALL continue to work with no re-layering of configuration

