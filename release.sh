#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────────────────────────
# DockMaster Pro — Website Release Script
#
# Usage:
#   ./release.sh                        # 交互模式
#   ./release.sh 1.4.0                  # 指定版本
#   ./release.sh 1.4.0 --notes notes.txt  # 从文件读取发布内容（每行一条）
#   ./release.sh 1.4.0 --date "May 1, 2026"  # 自定义日期
#   ./release.sh 1.4.0 --no-commit      # 只改文件，不提交
#
# 脚本会自动:
#   1. 收集发布内容（交互输入或文件读取）
#   2. 更新 releases.html（插入新版本块、移除旧 Latest 标签、更新底部下载链接）
#   3. 更新 index.html（hero badge 版本号、底部下载链接）
#   4. 展示 diff 预览
#   5. 可选：git commit + push
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RELEASES_HTML="${SCRIPT_DIR}/releases.html"
INDEX_HTML="${SCRIPT_DIR}/index.html"
GITHUB_REPO="devlive-community/DockMaster-Pro"
DOWNLOAD_BASE="https://github.com/${GITHUB_REPO}/releases/download"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${BLUE}▶ $*${NC}"; }
success() { echo -e "${GREEN}✓ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $*${NC}"; }
error()   { echo -e "${RED}✗ $*${NC}"; exit 1; }
step()    { echo -e "\n${BOLD}${CYAN}── $* ──${NC}"; }

# ── Parse args ────────────────────────────────────────────────────────────────
VERSION=""
NOTES_FILE=""
RELEASE_DATE=""
NO_COMMIT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --notes)        NOTES_FILE="$2"; shift 2 ;;
        --notes-file)   NOTES_FILE="$2"; shift 2 ;;
        --date)         RELEASE_DATE="$2"; shift 2 ;;
        --no-commit)    NO_COMMIT=true; shift ;;
        --help|-h)
            sed -n '/^# Usage:/,/^# ─/{ /^# ─/d; s/^# \{0,3\}//; p }' "$0"
            exit 0 ;;
        -*)             error "Unknown option: $1" ;;
        *)              VERSION="$1"; shift ;;
    esac
done

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   DockMaster Pro — Website Release Tool   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# ── Prereqs ───────────────────────────────────────────────────────────────────
step "Checking prerequisites"

command -v python3 &>/dev/null || error "python3 is required"
[ -f "$RELEASES_HTML" ] || error "releases.html not found in $(pwd)"
[ -f "$INDEX_HTML" ]    || error "index.html not found in $(pwd)"
success "All prerequisites met"

# ── Version ───────────────────────────────────────────────────────────────────
step "Version"

# Detect current latest version from releases.html
CURRENT_VERSION=$(python3 - <<'EOF'
import re, sys
html = open("releases.html").read()
m = re.search(r'<span class="release-tag">v([\d.]+)</span>', html)
print(m.group(1) if m else "unknown")
EOF
)
echo -e "Current latest : ${GREEN}v${CURRENT_VERSION}${NC}"

if [ -z "$VERSION" ]; then
    IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"
    echo ""
    echo "Suggested next versions:"
    echo -e "  ${CYAN}1${NC}) ${major}.$((minor + 1)).0  — minor release"
    echo -e "  ${CYAN}2${NC}) ${major}.${minor}.$((patch + 1))  — patch release"
    echo -e "  ${CYAN}3${NC}) $((major + 1)).0.0  — major release"
    echo ""
    read -rp "Enter new version (e.g. 1.4.0): " VERSION
fi

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || \
    error "Invalid version format '${VERSION}'. Expected MAJOR.MINOR.PATCH"

[ "$VERSION" = "$CURRENT_VERSION" ] && \
    error "Version v${VERSION} is already the current latest in releases.html"

success "New version: v${VERSION}"

# ── Date ──────────────────────────────────────────────────────────────────────
if [ -z "$RELEASE_DATE" ]; then
    RELEASE_DATE=$(date "+%B %-d, %Y")  # e.g. "April 16, 2026"
fi
echo -e "Release date   : ${GREEN}${RELEASE_DATE}${NC}"

# ── Release Notes ─────────────────────────────────────────────────────────────
step "Release notes"

declare -a NOTES_ITEMS

if [ -n "$NOTES_FILE" ]; then
    # Read from file — skip empty lines and comment lines
    [ -f "$NOTES_FILE" ] || error "Notes file not found: ${NOTES_FILE}"
    while IFS= read -r line; do
        line="${line#"${line%%[![:space:]]*}"}"  # ltrim
        [[ -z "$line" || "$line" == \#* ]] && continue
        NOTES_ITEMS+=("$line")
    done < "$NOTES_FILE"
    echo "Loaded ${#NOTES_ITEMS[@]} items from ${NOTES_FILE}"
else
    # Interactive input
    echo -e "${YELLOW}Enter release notes items one by one.${NC}"
    echo -e "Press ${CYAN}Enter${NC} on an empty line when done (minimum 1 item required).\n"
    idx=1
    while true; do
        read -rp "  Item ${idx}: " item
        item="${item#"${item%%[![:space:]]*}"}"
        [ -z "$item" ] && { [ ${#NOTES_ITEMS[@]} -gt 0 ] && break || { warn "At least one item required."; continue; }; }
        NOTES_ITEMS+=("$item")
        ((idx++))
    done
fi

echo ""
echo -e "${BOLD}Release notes preview (${#NOTES_ITEMS[@]} items):${NC}"
for i in "${!NOTES_ITEMS[@]}"; do
    echo -e "  ${CYAN}$((i+1)).${NC} ${NOTES_ITEMS[$i]}"
done

# ── Confirm ───────────────────────────────────────────────────────────────────
echo ""
read -rp "$(echo -e "${BOLD}Proceed to update HTML files? (y/N): ${NC}")" confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { warn "Aborted."; exit 0; }

# ── Update HTML via Python ────────────────────────────────────────────────────
step "Updating releases.html"

python3 - "$VERSION" "$RELEASE_DATE" "$DOWNLOAD_BASE" "${NOTES_ITEMS[@]}" <<'PYEOF'
import sys, re

version      = sys.argv[1]
date         = sys.argv[2]
dl_base      = sys.argv[3]
items        = sys.argv[4:]

# ── Build download SVG helper ──────────────────────────────────────────────
dl_svg = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>'

# ── Build <li> items ──────────────────────────────────────────────────────
li_items = "\n".join(f"                    <li>{i}</li>" for i in items)

# ── Build new release block ───────────────────────────────────────────────
LATEST_BADGE = (
    '<span style="display: inline-block; margin-left: 12px; padding: 4px 12px; '
    'background: var(--accent-glow); border-radius: 12px; font-size: 12px; '
    'color: var(--accent-light);">Latest</span>'
)

new_block = f'''\
        <div class="release-item fade-in">
            <div class="release-header">
                <div>
                    <span class="release-tag">v{version}</span>
                    {LATEST_BADGE}
                </div>
                <span class="release-date">{date}</span>
            </div>
            <div class="release-notes">
                <h3>🚀 New Features</h3>
                <ul>
{li_items}
                </ul>
            </div>
            <div class="release-assets">
                <a href="{dl_base}/v{version}/DockMasterPro_v{version}_universal.zip" class="release-asset">
                    {dl_svg}
                    Universal
                </a>
                <a href="{dl_base}/v{version}/DockMasterPro_v{version}_arm64.zip" class="release-asset">
                    {dl_svg}
                    Apple Silicon
                </a>
                <a href="{dl_base}/v{version}/DockMasterPro_v{version}_x86_64.zip" class="release-asset">
                    {dl_svg}
                    Intel
                </a>
            </div>
        </div>
'''

html = open("releases.html").read()

# 1. Remove "Latest" badge from the current first release item
html = html.replace(LATEST_BADGE, "", 1)

# 2. Insert new block right after <div class="releases-list">
anchor = '<div class="releases-list">'
pos = html.find(anchor)
if pos == -1:
    print("ERROR: Could not find .releases-list in releases.html", file=sys.stderr)
    sys.exit(1)
insert_at = pos + len(anchor) + 1   # +1 for the newline after the div
html = html[:insert_at] + new_block + html[insert_at:]

# 3. Update bottom #download section links (replace all old version download links)
old_ver_pattern = re.compile(
    r'(href="https://github\.com/[^"]+/releases/download/v)([\d.]+)(/DockMasterPro_v)([\d.]+)(_(?:universal|arm64|x86_64)\.zip")',
)
html = old_ver_pattern.sub(
    lambda m: f'{m.group(1)}{version}{m.group(3)}{version}{m.group(5)}',
    html
)

open("releases.html", "w").write(html)
print(f"releases.html updated with v{version}")
PYEOF

success "releases.html updated"

# ── Update index.html ─────────────────────────────────────────────────────────
step "Updating index.html"

python3 - "$VERSION" "$DOWNLOAD_BASE" <<'PYEOF'
import sys, re

version  = sys.argv[1]
dl_base  = sys.argv[2]

html = open("index.html").read()

# 1. Update hero badge version  (e.g. "v1.3.0 — Now Available")
html = re.sub(
    r'v[\d]+\.[\d]+\.[\d]+\s*—\s*Now Available',
    f'v{version} — Now Available',
    html
)

# 2. Update all download link hrefs in index.html
html = re.sub(
    r'(href="https://github\.com/[^"]+/releases/download/v)([\d.]+)(/DockMasterPro_v)([\d.]+)(_(?:universal|arm64|x86_64)\.zip")',
    lambda m: f'{m.group(1)}{version}{m.group(3)}{version}{m.group(5)}',
    html
)

open("index.html", "w").write(html)
print(f"index.html updated to v{version}")
PYEOF

success "index.html updated"

# ── Diff preview ──────────────────────────────────────────────────────────────
step "Changes preview"

git diff --stat 2>/dev/null || true
echo ""

# ── Commit & Push ─────────────────────────────────────────────────────────────
if [ "$NO_COMMIT" = true ]; then
    warn "--no-commit specified. Files updated but not committed."
else
    read -rp "$(echo -e "${BOLD}Commit and push? (y/N): ${NC}")" push_confirm
    if [[ "$push_confirm" =~ ^[Yy]$ ]]; then
        step "Committing & pushing"

        git add releases.html index.html
        git commit -m "docs: add v${VERSION} release notes and update to latest version"
        git push

        success "Pushed to remote"
        echo ""
        echo -e "  ${GREEN}→${NC} https://github.com/${GITHUB_REPO}"
    else
        warn "Files updated locally. Run 'git add releases.html index.html && git commit' when ready."
    fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Release v${VERSION} ready!              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Version${NC}   v${VERSION}"
echo -e "  ${BOLD}Date${NC}      ${RELEASE_DATE}"
echo -e "  ${BOLD}Items${NC}     ${#NOTES_ITEMS[@]} release notes"
echo -e "  ${BOLD}Files${NC}     releases.html, index.html"
echo ""
