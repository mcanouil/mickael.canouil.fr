#!/usr/bin/env bash
# Capture the screenshots and the preview animation used by this post.
#
# Usage: ./capture.sh [light|dark|both]
#
# The script writes its own fixture project to /tmp, opens it in a throwaway
# Visual Studio Code profile, drives the editor over AppleScript, and writes the
# images straight into ../media, at the size the post uses.
#
# It needs:
#   - Quarto Wizard 3.3 or later, the GitHub theme, and the Quarto extension in
#     ~/.vscode/extensions;
#   - the typst-render extension of this website, under _extensions/mcanouil;
#   - Screen Recording and Accessibility permission for the terminal that runs
#     the script, which on an integrated terminal means Visual Studio Code
#     itself;
#   - screencapture and osascript from macOS, magick and img2webp from
#     Homebrew, and uv for the pointer moves.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POST="$(cd "${HERE}/../.." && pwd)"
SITE="$(cd "${POST}/../.." && pwd)"
OUT="${OUT:-${POST}/assets/media}"

# Short paths: a long --user-data-dir breaks the 103 character IPC socket limit,
# and the fixture path shows up in a tooltip, so keep it readable.
WORKSPACE=/tmp/qw-demo
PROFILE=/tmp/qw-shot
EXTDIR=/tmp/qw-ext
FRAMES=/tmp/qw-frames
CODE_BIN="/Applications/Visual Studio Code.app/Contents/MacOS/Code"

WANT_X=60
WANT_Y=80
WANT_W=1340
WANT_H=720

# Filled from the window itself after every raise, because the window manager
# does not always grant the requested size.
WIN_X=0
WIN_Y=0
WIN_W=0
WIN_H=0

# Editor text metrics, measured from a capture. The column step is in tenths of
# a point, and the two vertical offsets are in points from the top of the
# window. A code lens takes a row of its own and is shorter than a line of
# text, so a row is not a line and the offsets are measured, not computed.
EDITOR_DX=66
CHAR_W10=72
Y_PREAMBLE=376
Y_RECT=729

THEME_LIGHT="GitHub Light"
THEME_DARK="GitHub Dark Dimmed"

# Width of the images in the post. The captures are twice that, for a screen
# with two pixels per point.
POST_WIDTH=1400

log() { printf '%s\n' "== $*" >&2; }

prepare_extensions() {
	# One directory holding only what a shot shows, so no other extension of
	# yours appears in the window.
	local id dir
	mkdir -p "${EXTDIR}"
	for id in mcanouil.quarto-wizard github.github-vscode-theme quarto.quarto; do
		if ! compgen -G "${EXTDIR}/${id}-*" >/dev/null; then
			for dir in "${HOME}"/.vscode/extensions/"${id}"-*; do
				[ -d "${dir}" ] || continue
				cp -R "${dir}" "${EXTDIR}/"
			done
		fi
		compgen -G "${EXTDIR}/${id}-*" >/dev/null || {
			log "${id} is not installed in ~/.vscode/extensions"
			exit 1
		}
	done
}

prepare_workspace() {
	# The fixture lives here rather than beside the script, so this folder holds
	# no .qmd and no _quarto.yml that the website would try to render.
	rm -rf "${WORKSPACE}"
	mkdir -p "${WORKSPACE}/_extensions/mcanouil"
	cp -R "${SITE}/_extensions/mcanouil/typst-render" "${WORKSPACE}/_extensions/mcanouil/"

	cat >"${WORKSPACE}/_preamble.typ" <<'TYP'
#import "@preview/gribouille:0.7.0": *
TYP

	# The cell asks for auto colours, which read the two sides of the brand, so
	# the image matches the theme of the editor.
	cat >"${WORKSPACE}/_brand-light.yml" <<'YAML'
color:
  palette:
    ink: "#1f2328"
    paper: "#ffffff"
  foreground: ink
  background: paper
YAML

	cat >"${WORKSPACE}/_brand-dark.yml" <<'YAML'
color:
  palette:
    ink: "#e6edf3"
    paper: "#22272e"
  foreground: ink
  background: paper
YAML

	# dpi holds a string and margine is not a key of the schema, which is what
	# the diagnostics shot reports.
	cat >"${WORKSPACE}/_quarto.yml" <<'YAML'
project:
  title: "Typst preview demo"

brand:
  light: _brand-light.yml
  dark: _brand-dark.yml

extensions:
  typst-render:
    format: svg
    dpi: high
    margine: "0.5em"
YAML

	# The line and column numbers below are used by the capture, so keep the
	# layout of this file and the constants in step.
	cat >"${WORKSPACE}/demo.qmd" <<'QMD'
---
title: "Typst preview demo"
format: typst
extensions:
  typst-render:
    preamble: _preamble.typ
---

## A Typst cell

```{typst}
//| width: 11cm
//| height: 8cm
//| background: auto
//| foreground: auto
//| preamble: _preamble.typ
#plot(
  data: penguins,
  mapping: aes(x: "flipper-len", y: "body-mass", colour: "species"),
  layers: (geom-point(),),
)
```

## A raw block

```{=typst}
#box(inset: 6pt, radius: 3pt, stroke: 0.6pt)[Raw Typst, straight to the output.]
```

## A plain block

```typst
#rect(width: 5cm, height: 2cm, radius: 4pt, stroke: 0.8pt)[
  #align(center + horizon)[Preview me]
]
```
QMD
}

write_settings() {
	local theme="$1" surface="$2"
	# A fresh profile every run: no restored buffer, no restored panel, and no
	# side bar state carried over. The chat settings keep the dialog away.
	rm -rf "${PROFILE}"
	mkdir -p "${PROFILE}/User"
	cat >"${PROFILE}/User/settings.json" <<JSON
{
  "workbench.colorTheme": "${theme}",
  "workbench.startupEditor": "none",
  "workbench.activityBar.location": "hidden",
  "workbench.statusBar.visible": false,
  "workbench.tips.enabled": false,
  "workbench.layoutControl.enabled": false,
  "workbench.secondarySideBar.defaultVisibility": "hidden",
  "workbench.welcomePage.walkthroughs.openOnInstall": false,
  "workbench.editor.editorActionsLocation": "hidden",
  "window.commandCenter": false,
  "window.titleBarStyle": "native",
  "window.zoomLevel": 0,
  "editor.fontFamily": "MesloLGS NF, Menlo, Monaco, monospace",
  "editor.fontSize": 12,
  "editor.lineHeight": 19,
  "editor.minimap.enabled": false,
  "editor.scrollBeyondLastLine": false,
  "editor.stickyScroll.enabled": false,
  "breadcrumbs.enabled": false,
  "security.workspace.trust.enabled": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "none",
  "extensions.autoCheckUpdates": false,
  "files.hotExit": "off",
  "chat.commandCenter.enabled": false,
  "chat.disableAIFeatures": true,
  "quartoWizard.typstPreview.surface": "${surface}",
  "quartoWizard.typstPreview.debounceMs": 150
}
JSON
}

osa() { osascript "$@"; }

CAPTURE_PID=""

find_capture_pid() {
	# The window owning process is the one without a --type= flag. No head in
	# the pipeline: it closes the pipe early and the shell dies on SIGPIPE.
	local pid pids
	CAPTURE_PID=""
	pids="$(pgrep -f "user-data-dir ${PROFILE}" || true)"
	for pid in ${pids}; do
		case "$(ps -o command= -p "${pid}")" in
		*--type=*) : ;;
		*)
			CAPTURE_PID="${pid}"
			break
			;;
		esac
	done
	[ -n "${CAPTURE_PID}" ] || {
		log "the capture instance is not running"
		exit 1
	}
}

# Several instances of Visual Studio Code run at once, and one of them may be
# yours, so every event is addressed to the process id of the capture instance
# and never to the name "Code".
proc_tell() {
	osa -e "tell application \"System Events\" to tell (first application process whose unix id is ${CAPTURE_PID}) to $1"
}

front_window_name() {
	proc_tell 'get name of front window' 2>/dev/null || true
}

launch_code() {
	log "launching the capture window"
	"${CODE_BIN}" --user-data-dir "${PROFILE}" --extensions-dir "${EXTDIR}" \
		--new-window "${WORKSPACE}" >/tmp/qw-launch.log 2>&1 &
	sleep 22
	find_capture_pid
	position_window
	# A first run offers a sign in dialog; Escape closes it.
	proc_tell 'key code 53' || true
	sleep 1
	proc_tell 'key code 53' || true
	sleep 1
	# Close the file tree with the command and not the toggle, because the
	# command says what it does whatever the current state, and run it twice in
	# case the window was still busy the first time. Then focus the editor.
	run_command "View: Close Primary Side Bar" 2
	run_command "View: Close Primary Side Bar" 2
	run_command "View: Close Secondary Side Bar" 2
	proc_tell 'keystroke "1" using {command down}' || true
	sleep 1
}

position_window() {
	local try name
	for try in 1 2 3 4 5 6 7 8 9 10; do
		osa >/dev/null 2>&1 <<EOF || true
tell application "System Events"
  tell (first application process whose unix id is ${CAPTURE_PID})
    set frontmost to true
    set target to window 1
    perform action "AXRaise" of target
    set value of attribute "AXMain" of target to true
    set position of target to {${WANT_X}, ${WANT_Y}}
    set size of target to {${WANT_W}, ${WANT_H}}
  end tell
end tell
EOF
		sleep 1.5
		name="$(front_window_name)"
		case "${name}" in
		*.qmd* | *.yml* | *qw-demo*)
			read_window_bounds
			return 0
			;;
		esac
		log "front window is '${name}', retrying (${try})"
		sleep 2
	done
	log "could not bring the capture window to the front"
	exit 1
}

read_window_bounds() {
	local bounds
	bounds="$(
		osa <<EOF
tell application "System Events"
  tell (first application process whose unix id is ${CAPTURE_PID})
    set p to position of window 1
    set s to size of window 1
    return (item 1 of p as text) & " " & (item 2 of p as text) & " " & (item 1 of s as text) & " " & (item 2 of s as text)
  end tell
end tell
EOF
	)"
	read -r WIN_X WIN_Y WIN_W WIN_H <<<"${bounds}"
}

# A keystroke goes to whatever window is in front, so refuse to type when the
# front window is not the capture one.
guard_window() {
	local name
	name="$(front_window_name)"
	case "${name}" in
	*.qmd* | *.yml* | *qw-demo*) : ;;
	*)
		log "front window is '${name}', not the capture window; stopping"
		exit 1
		;;
	esac
}

stop_code() {
	# A plain quit asks about the buffers the capture edited, so end the
	# instance outright and wait until every process is gone.
	log "closing the capture window"
	pkill -9 -f "user-data-dir ${PROFILE}" || true
	local try
	for try in 1 2 3 4 5 6 7 8 9 10; do
		pgrep -f "user-data-dir ${PROFILE}" >/dev/null 2>&1 || break
		sleep 1
	done
	sleep 2
}

goto() {
	# goto <file> <line> <column>, through the command line and not a keystroke
	"${CODE_BIN}" --user-data-dir "${PROFILE}" --extensions-dir "${EXTDIR}" \
		--reuse-window --goto "${WORKSPACE}/$1:$2:$3" >/dev/null 2>&1
	sleep 2
	position_window
	proc_tell 'keystroke "1" using {command down}' || true
	sleep 0.5
}

type_text() {
	guard_window
	proc_tell "keystroke \"$1\""
}

send_return() { proc_tell 'key code 36'; }

select_left() {
	# select_left <count>, one character at a time
	local n="$1" i
	for ((i = 0; i < n; i++)); do
		proc_tell 'key code 123 using {shift down}'
	done
}

run_command() {
	# run_command <command name> [seconds to wait]
	guard_window
	proc_tell 'keystroke "p" using {command down, shift down}'
	sleep 0.7
	type_text "$1"
	sleep 1.2
	send_return
	sleep "${2:-6}"
}

mouse_to() {
	uv run --quiet --with pyobjc-framework-Quartz python - "$1" "$2" <<'PY'
import sys
import Quartz

x, y = float(sys.argv[1]), float(sys.argv[2])
event = Quartz.CGEventCreateMouseEvent(None, Quartz.kCGEventMouseMoved, (x, y), 0)
Quartz.CGEventPost(Quartz.kCGHIDEventTap, event)
PY
	sleep 0.4
}

hover_point() {
	# hover_point <column> <y offset in points from the top of the window>. Two
	# moves, because a single warp does not always wake the hover.
	local col="$1" dy="$2" x y
	x=$((WIN_X + EDITOR_DX + (col * CHAR_W10) / 10))
	y=$((WIN_Y + dy))
	mouse_to $((x - 40)) $((y - 12))
	mouse_to "${x}" "${y}"
}

shot() {
	local name="$1"
	sleep 1
	screencapture -x -o -R"${WIN_X},${WIN_Y},${WIN_W},${WIN_H}" "/tmp/qw-${name}"
	magick "/tmp/qw-${name}" -resize "${POST_WIDTH}x" -strip \
		-define png:compression-level=9 "${OUT}/${name}"
	log "wrote ${OUT}/${name}"
}

ANIM_INDEX=0

frame() {
	ANIM_INDEX=$((ANIM_INDEX + 1))
	screencapture -x -R"${WIN_X},${WIN_Y},${WIN_W},${WIN_H}" \
		"$(printf '%s/f%03d.png' "${FRAMES}" "${ANIM_INDEX}")"
}

capture_animation() {
	# The cursor visits the three kinds of block in turn, and every edit keeps
	# the block valid, so the preview never has to report a failure here.
	local out="${OUT}/$1"
	ANIM_INDEX=0
	mkdir -p "${FRAMES}"
	rm -f "${FRAMES}"/*.png
	local _ value

	for _ in 1 2; do
		frame
		sleep 0.3
	done

	# The cell: change the height the extension gives the image.
	for value in "6cm" "9cm" "8cm"; do
		select_left 3
		sleep 0.2
		type_text "${value}"
		sleep 1.4
		frame
	done

	# The raw block: the preview follows the cursor.
	goto demo.qmd 27 10
	sleep 3
	frame
	frame

	# The plain block: change the width of the rectangle.
	goto demo.qmd 33 17
	sleep 3
	frame
	for value in "7cm" "5cm"; do
		select_left 3
		sleep 0.2
		type_text "${value}"
		sleep 1.2
		frame
	done

	for _ in 1 2; do
		frame
		sleep 0.4
	done

	magick mogrify -resize 1200x -path "${FRAMES}" "${FRAMES}"/*.png
	img2webp -loop 0 -d 550 -q 72 "${FRAMES}"/*.png -o "${out}"
	log "wrote ${out}"
}

capture_profile() {
	# capture_profile <light|dark> <theme name>
	local side="$1" theme="$2"

	write_settings "${theme}" "panel"
	launch_code

	# Schema diagnostics run on a change and not on opening, so nudge the file.
	goto _quarto.yml 11 10
	type_text " "
	sleep 0.5
	proc_tell 'key code 51'
	sleep 6
	run_command "Problems: Focus on Problems View" 3
	shot "schema-diagnostics-${side}.png"
	run_command "View: Close Panel" 2

	# The link a path option carries, under the command key.
	goto demo.qmd 16 19
	hover_point 19 "${Y_PREAMBLE}"
	osa -e 'tell application "System Events" to key down command'
	sleep 2
	shot "typst-option-link-${side}.png"
	osa -e 'tell application "System Events" to key up command'

	# The panel, then the authoring loop over the three kinds of block.
	goto demo.qmd 13 16
	run_command "Preview Typst Block" 25
	shot "typst-preview-panel-${side}.png"
	capture_animation "typst-preview-loop-${side}.webp"

	# A failure keeps the last good image and says what went wrong. The cursor
	# is still after the width of the rectangle, so 5cm becomes 5m.
	select_left 2
	sleep 0.2
	type_text "m"
	sleep 1
	proc_tell 'key code 53'
	sleep 5
	shot "typst-preview-error-${side}.png"

	stop_code

	# The hover surface needs its own window, because the setting is read once.
	write_settings "${theme}" "hover"
	launch_code
	goto demo.qmd 33 20
	hover_point 20 "${Y_RECT}"
	sleep 8
	shot "typst-preview-hover-${side}.png"
	stop_code
}

main() {
	mkdir -p "${OUT}" "${FRAMES}"
	prepare_extensions
	prepare_workspace
	case "${1:-both}" in
	light) capture_profile light "${THEME_LIGHT}" ;;
	dark) capture_profile dark "${THEME_DARK}" ;;
	both)
		capture_profile light "${THEME_LIGHT}"
		capture_profile dark "${THEME_DARK}"
		;;
	*)
		printf 'usage: %s [light|dark|both]\n' "$0" >&2
		exit 2
		;;
	esac
	log "done, files are in ${OUT}"
}

main "$@"
