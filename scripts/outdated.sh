#!/usr/bin/env bash
# outdated.sh — report which installed tools are not at their versions.lock
# pin, and the make command that puts each one back. Read-only: it installs
# nothing and writes nothing.
#
#   UPSTREAM=1 make outdated   also look up every tool's newest release, with
#                              the lookups 'make freeze' makes, to show which
#                              pins have fallen behind. That is ~40 GitHub API
#                              calls: export GITHUB_TOKEN if you hit 60/hour.
#
# Where the installed version comes from:
#   ~/bin tools  ~/bin/.installed.lock, which each installer updates
#                (record_install in lib.sh). A tool installed before that
#                record existed has no line there, so it is asked for its
#                version instead, shown with a ~: the first dotted number it
#                prints, set against the pin's. sendcb, notify, showimg and
#                termcheck print no version, so their file is compared with the
#                pinned commit's copy (raw.githubusercontent.com, not the API).
#   conda tools  conda's own list of the base environment
#   pip tools    the tool's --version
# A tool on PATH that this repo didn't install (a distro's jq in /usr/bin, say)
# is listed as elsewhere and never run: 'make install' skips those too, unless
# FORCE=1.
set -uo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
set +e   # this script only reports; keep going past anything unreadable

: "${UPSTREAM:=0}"

# --- the tools ---------------------------------------------------------------
# name|channel|command|make target|forge repo|hint, for an opt-in extra
tools=()
while IFS=$'\t' read -r name repo _ bins; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  bins="${bins:-$name}"
  tools+=("$name|gh|${bins%% *}|$name|$repo|")
done < "$ROOTDIR/binaries.tsv"
tools+=("ollama|gh|ollama|ollama|ollama/ollama|")
for t in sendcb notify showimg termcheck; do tools+=("$t|git|$t|$t|davetang/$t|"); done
for t in tmux zsh datamash parallel pv goaccess xclip ncdu tree pigz; do
  tools+=("$t|conda|$t|$t||")
done
tools+=("gnu-coreutils|conda|gls|coreutils||"
        "visidata|pip|vd|visidata||"
        "llm|pip|llm|llm||"
        "screen|gnu|screen|screen||"
        "go|go|go|go||make sdks"
        "openjdk|adoptium|java|openjdk||make sdks"
        "rig|gh|rig|rig|r-lib/rig|make rig")

# --- conda's list of the base environment ------------------------------------
# Not _conda_setup: with no conda it bootstraps Miniforge, and a report should
# install nothing.
declare -A conda_has=()
condabin="$(command -v conda 2>/dev/null)"
[[ -z "$condabin" && -x "$HOME/miniforge3/bin/conda" ]] && condabin="$HOME/miniforge3/bin/conda"
if [[ -n "$condabin" ]]; then
  while IFS=$'\t' read -r n v; do
    [[ -n "$n" ]] && conda_has[$n]="$v"
  done < <("$condabin" list -n base --json 2>/dev/null | python3 -c '
import json, sys
for p in json.load(sys.stdin):
    print(p["name"] + "\t" + p["version"])' 2>/dev/null)
fi

# --- reading versions --------------------------------------------------------
# _run <command...>: run with stdin closed, and give up after 5 s: ollama, for
# one, tries to reach its server before it reports its version.
_run() {
  if have timeout; then timeout 5 "$@" </dev/null; else "$@" </dev/null; fi
}

# ask <path> <command>: the first dotted number the tool prints about itself.
# Most answer --version; these few don't. java prints the bare feature release
# for a .0 release ("25"), so take what it quotes instead.
ask() {
  local -a args=(--version)
  case "$2" in
    csvtk|seqkit|go) args=(version) ;;
    tt|screen)       args=(-v) ;;
    java) _run "$1" -version 2>&1 | sed -nE 's/.*version "([^"]+)".*/\1/p' | head -1
          return ;;
  esac
  _run "$1" "${args[@]}" 2>&1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1
}

# same_file <repo> <sha> <path>: 0 if <path> is byte for byte the file of that
# name at commit <sha>, 1 if it isn't, 2 if that copy couldn't be fetched.
same_file() {
  curl -fsSL --retry 3 --connect-timeout 20 -o "$TMP/pinned" \
    "https://raw.githubusercontent.com/$1/$2/${3##*/}" 2>/dev/null || return 2
  cmp -s "$TMP/pinned" "$3"
}

# jver <release or java -version>: the Java version both spell, minus the
# build: jdk-21.0.8+9 and 21.0.8 -> 21.0.8; jdk8u462-b08 and 1.8.0_462 -> 8u462.
# jfeature: its feature release (21, 8), what versions.lock pins.
jver() {
  local v="${1#jdk-}"; v="${v#jdk}"; v="${v%%[+-]*}"
  [[ "$v" =~ ^1\.8\.0_([0-9]+) ]] && v="8u${BASH_REMATCH[1]}"
  printf '%s\n' "$v"
}
jfeature() { local v; v="$(jver "$1")"; printf '%s\n' "${v%%[.u]*}"; }

# upstream <name> <channel> <repo> <pin> <installed>: the newest release, as
# freeze.sh would pin it. openjdk's pin is a feature release that freeze leaves
# alone, so its newest is the newest patch of that feature (or, unpinned, of the
# one installed): what 'make openjdk' installs.
upstream() {
  case "$2" in
    gh)       forge_latest_tag "$3" ;;
    git)      forge_latest_commit "$3" ;;
    conda)    conda_latest_version "$1" ;;
    pip)      pypi_latest_version "$1" ;;
    gnu)      gnu_latest_version "$1" ;;
    go)       go_latest_version ;;
    adoptium) local f="${4:-$(jfeature "$5")}"
              [[ -n "$f" ]] && adoptium_latest_release "$f" ;;
  esac
}

# --- comparing ---------------------------------------------------------------
_vnum() { grep -oE '[0-9]+(\.[0-9]+)+' <<<"$1" | head -1; }

# verdict <installed> <reference> <exact>: ok, older, newer or differs. Any
# prefix before the first digit is dropped, so v0.26.1, 0.26.1 and jq-1.8.1's
# 1.8.1 compare as numbers. exact=1 compares the rest whole (a recorded tag,
# conda's list: 3.5a is older than 3.5b); exact=0 only the first dotted number
# of each, which is all a tool's --version output can be trusted for.
verdict() {
  local a="${1#"${1%%[0-9]*}"}" b="${2#"${2%%[0-9]*}"}"
  if [[ "$3" != 1 ]]; then a="$(_vnum "$a")"; b="$(_vnum "$b")"; fi
  [[ -n "$a" && -n "$b" ]] || { echo differs; return; }
  [[ "$a" == "$b" ]] && { echo ok; return; }
  [[ "$(printf '%s\n' "$a" "$b" | sort -V | head -1)" == "$a" ]] && echo older || echo newer
}

# show <channel> <value>: a table cell; commits shortened as git does.
show() {
  [[ -n "$2" ]] || { echo -; return; }
  if [[ "$1" == git && "$2" =~ ^[0-9a-f]{40}$ ]]; then echo "${2:0:7}"; else echo "$2"; fi
}

# --- the report --------------------------------------------------------------
[[ "$UPSTREAM" == 1 ]] && log "looking up each tool's newest release (about 60 requests)…"

printf '%-14s %-16s %-16s' TOOL INSTALLED PINNED
[[ "$UPSTREAM" == 1 ]] && printf ' %-16s' LATEST
printf ' %s\n' STATUS
printf '%-14s %-16s %-16s' ---- --------- ------
[[ "$UPSTREAM" == 1 ]] && printf ' %-16s' ------
printf ' %s\n' ------

outdated=() newer=() unknown=() missing=() elsewhere=() behind=()
n_ours=0 n_ok=0 n_unpinned=0 probed=0 gh_down=
for row in "${tools[@]}"; do
  IFS='|' read -r name ch cmd target repo extra <<<"$row"
  pin="$(lock_get "$name" "$ch")"

  # where: ours, elsewhere, or empty when it isn't installed at all
  where= iv= mark= exact=1 differs=
  case "$ch" in
    conda)
      if [[ -n "${conda_has[$name]:-}" ]]; then where=ours; iv="${conda_has[$name]}"
      elif have "$cmd"; then where=elsewhere; fi ;;
    pip)
      if p="$(command -v "$cmd")"; then where=ours; iv="$(ask "$p" "$cmd")"; exact=0; fi ;;
    *)
      if [[ -x "$BIN/$cmd" ]]; then
        where=ours
        iv="$(installed_get "$name" "$ch")"
        if [[ -z "$iv" && "$ch" == git ]]; then
          if [[ -n "$pin" ]]; then
            same_file "$repo" "$pin" "$BIN/$cmd"
            case $? in 0) iv="$pin" ;; 1) differs=1 ;; esac
          fi
        elif [[ -z "$iv" ]]; then
          iv="$(ask "$BIN/$cmd" "$cmd")"; exact=0
          [[ -n "$iv" ]] && { mark='~'; probed=$((probed+1)); }
        fi
      elif have "$cmd"; then where=elsewhere; fi ;;
  esac

  # Once GitHub stops answering (the 60/hour limit), skip the rest of it
  # rather than print the same error forty times.
  latest= on_github=
  [[ ( "$ch" == gh || "$ch" == git ) && "$repo" != */*/* ]] && on_github=1
  if [[ "$UPSTREAM" == 1 && -z "${on_github:+$gh_down}" ]]; then
    latest="$(upstream "$name" "$ch" "$repo" "$pin" "$iv")"
    [[ -z "$latest" && -n "$on_github" ]] && gh_down=1
  fi

  # Unpinned, the reference is upstream's newest (what an install would get).
  ref="${pin:-$latest}"
  sc="$_c_yellow" is_behind=
  if [[ -z "$where" ]]; then
    if [[ -n "$extra" ]]; then status="-  $extra"; sc=
    else status=missing; missing+=("$target"); fi
  elif [[ "$where" == elsewhere ]]; then
    status="elsewhere: $(command -v "$cmd")"; sc=; elsewhere+=("$target")
  else
    n_ours=$((n_ours+1))
    if [[ -n "$differs" ]]; then
      status=differs; outdated+=("$target")
    elif [[ -z "$iv" ]]; then
      status=unknown; unknown+=("$target")
    elif [[ -z "$ref" ]]; then
      status=unpinned; sc=; n_unpinned=$((n_unpinned+1))
    else
      case "$ch" in
        git)      [[ "$iv" == "$ref" ]] && v=ok || v=differs ;;
        adoptium) v="$(verdict "$(jfeature "$iv")" "${pin:-$(jfeature "$latest")}" 1)"
                  [[ "$v" == ok && -n "$latest" ]] && v="$(verdict "$(jver "$iv")" "$(jver "$latest")" 1)" ;;
        *)        v="$(verdict "$iv" "$ref" "$exact")" ;;
      esac
      case "$v" in
        ok)    status=ok; sc="$_c_green"; n_ok=$((n_ok+1)) ;;
        older) status=outdated; outdated+=("$target") ;;
        newer) status="newer than pin"; newer+=("$target") ;;
        *)     status=differs; outdated+=("$target") ;;
      esac
    fi
    # A pin behind upstream: 'make freeze' moves it, and then this needs a
    # reinstall, unless what is installed is the newest already. openjdk's pin
    # is kept by freeze; a newer patch of it shows up as outdated above instead.
    if [[ -n "$pin" && -n "$latest" && "$ch" != adoptium ]]; then
      if [[ "$ch" == git ]]; then
        [[ "$pin" == "$latest" ]] || is_behind=1
        [[ -n "$is_behind" && "$iv" != "$latest" ]] && behind+=("$target")
      elif [[ "$(verdict "$pin" "$latest" 1)" == older ]]; then
        is_behind=1
        [[ "$(verdict "$iv" "$latest" "$exact")" != ok ]] && behind+=("$target")
      fi
    fi
  fi

  # ? where there should be a version and none could be read
  icell="$mark$(show "$ch" "$iv")"; [[ "$where" == ours && -z "$iv" ]] && icell='?'
  printf '%-14s %-16s %-16s' "$name" "$icell" "$(show "$ch" "$pin")"
  if [[ "$UPSTREAM" == 1 ]]; then
    lc=; [[ -n "$is_behind" ]] && lc="$_c_yellow"
    cell="$(show "$ch" "$latest")"; [[ -z "$latest" ]] && cell='?'
    printf ' %s%-16s%s' "$lc" "$cell" "$_c_reset"
  fi
  printf ' %s%s%s\n' "$sc" "$status" "$_c_reset"
done

# --- what to do about it -----------------------------------------------------
echo
(( probed )) && printf '%s\n' \
  "~ the tool's own --version: it was installed before $RECORDFILE" \
  "  existed. FORCE=1 make <tool> reinstalls it and records the exact version." ""
ok "$n_ok of $n_ours installed tools at their pin"
(( ${#outdated[@]} )) && log "${#outdated[@]} not at their pin: FORCE=1 make ${outdated[*]}"
(( ${#newer[@]} ))    && log "${#newer[@]} newer than their pin: FORCE=1 make ${newer[*]} goes back to the pin, or pin what you have in versions.lock"
(( ${#unknown[@]} ))  && log "${#unknown[@]} with no version to compare: FORCE=1 make ${unknown[*]} reinstalls at the pin and records it"
(( n_unpinned ))      && log "$n_unpinned not pinned in versions.lock: UPSTREAM=1 make outdated compares them with the newest release"
(( ${#missing[@]} ))  && log "${#missing[@]} not installed: make ${missing[*]}"
(( ${#elsewhere[@]} )) && log "${#elsewhere[@]} on PATH but not installed by this repo, so not compared: FORCE=1 make ${elsewhere[*]} puts this repo's copy in front"
(( ${#behind[@]} ))   && log "${#behind[@]} pinned behind upstream: make freeze, then FORCE=1 make ${behind[*]}"
[[ -n "$gh_down" ]]   && warn "GitHub stopped answering, so the newest release of the rest of its tools is unknown (?) — export GITHUB_TOKEN, or wait for the hourly limit"
exit 0
