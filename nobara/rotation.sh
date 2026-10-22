#!/usr/bin/env bash
# rotation.sh — correct the Pocket 4 accelerometer at the device layer.
#
#   pkexec ~/Repos/dotfiles/nobara/rotation.sh          # apply
#   bash    ~/Repos/dotfiles/nobara/rotation.sh --dry-run
#   pkexec  ~/Repos/dotfiles/nobara/rotation.sh --touch # also install the
#                                                       # touchscreen matrix
#
# Fixes rotation for EVERY desktop instead of for one compositor. The old
# approach was a Hyprland daemon calling `hyprctl keyword monitor ... transform`
# against a hand-built lookup table; it stopped working the moment Hyprland did,
# and it never corrected the tilt readings at all.
#
# The touchscreen matrix is OPT-IN (--touch) on purpose. KWin already transforms
# touch with its output, so installing one unconditionally can double-apply it.
# See the header of dist/99-touchscreen-calibration.rules.
#
# Idempotent: re-running installs the same files and re-triggers udev. It does
# not restart anything the system setup depends on.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST="$HERE/dist"
DRY=0
TOUCH=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1; shift ;;
    --touch)   TOUCH=1; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

c_b=$'\033[1;34m'; c_y=$'\033[1;33m'; c_0=$'\033[0m'
step() { printf '%s==>%s %s\n' "$c_b" "$c_0" "$*"; }
warn() { printf '%s !%s %s\n' "$c_y" "$c_0" "$*"; }
run()  { if [ "$DRY" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else eval "$@"; fi; }

if [ "$DRY" != 1 ] && [ "$(id -u)" -ne 0 ]; then
  echo "must run as root (pkexec $0), or pass --dry-run to preview" >&2
  exit 1
fi

# The matrix is model-specific. Applying another model's matrix does not fail,
# it just reports the wrong orientation - so refuse rather than "work" wrongly.
VENDOR=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "")
MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
step "detected: ${VENDOR:-unknown} / ${MODEL:-unknown}"
if [ "$VENDOR" != "GPD" ] || [ "$MODEL" != "G1628-04" ]; then
  warn "this matrix was derived for GPD G1628-04 (systemd issue 41036)."
  warn "On $VENDOR $MODEL it would report the WRONG orientation. Refusing."
  warn "Derive a matrix for this model first — see dist/61-sensor-local.hwdb."
  exit 1
fi

step "1. accelerometer mount matrix"
run "install -D -m 0644 -o root -g root '$DIST/61-sensor-local.hwdb' /etc/udev/hwdb.d/61-sensor-local.hwdb"

if [ "$TOUCH" = 1 ]; then
  step "2. touchscreen calibration (opt-in)"
  run "install -D -m 0644 -o root -g root '$DIST/99-touchscreen-calibration.rules' /etc/udev/rules.d/99-touchscreen-calibration.rules"
  run "udevadm control --reload-rules"
else
  step "2. touchscreen calibration SKIPPED (pass --touch only if touch does not follow rotation)"
fi

step "3. rebuild the hardware database and re-trigger the sensor"
run "systemd-hwdb update"
run "udevadm trigger -p DEVNAME=/dev/iio:device0"
run "systemctl restart iio-sensor-proxy"

# Prove the property actually landed. hwdb ignores a malformed entry silently,
# so "installed the file" and "the kernel sees the matrix" are different claims.
if [ "$DRY" != 1 ]; then
  step "4. verify the property is live"
  if systemd-hwdb query 'sensor:modalias:acpi:MXC6655:*:dmi:*:svnGPD:pnG1628-04:*' 2>/dev/null | grep -q ACCEL_MOUNT_MATRIX; then
    echo "  ok: ACCEL_MOUNT_MATRIX resolves"
  else
    warn "hwdb does NOT resolve the matrix — check that the match line starts at"
    warn "column 0 and the property line starts with exactly one space."
    exit 1
  fi
fi

cat <<'EOF'

Now verify against the hardware with:

  monitor-sensor --accel

Rotate the machine and confirm all four:

  laptop (keyboard toward you) -> right-up
  rotated clockwise            -> normal
  keyboard up                  -> left-up
  keyboard right               -> bottom-up

Then check the tilt readings (vertical / tilted-up / tilted-down / horizontal),
which the old compositor script never corrected.

If any orientation is wrong, recover the old compositor daemon from git history
(home/dot_config/hypr/scripts/executable_auto-rotate.sh, deleted 2026-08-16)
and compare its label->transform table against what monitor-sensor reports.
EOF
