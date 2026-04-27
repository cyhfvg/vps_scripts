#!/bin/bash
# Update and back up external scripts used by vps.sh.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST_FILE="$PROJECT_ROOT/config/external_scripts.conf"
EXTERNAL_DIR="$PROJECT_ROOT/external_scripts"
BACKUP_ROOT="$PROJECT_ROOT/backups/external_scripts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }

ensure_downloader() {
    if command -v curl >/dev/null 2>&1; then
        DOWNLOADER="curl"
    elif command -v wget >/dev/null 2>&1; then
        DOWNLOADER="wget"
    else
        log_error "未找到 curl 或 wget，无法更新外部脚本。"
        exit 1
    fi
}

download_file() {
    local url="$1"
    local output="$2"

    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fsSL "$url" -o "$output"
    else
        wget -q "$url" -O "$output"
    fi
}

main() {
    ensure_downloader

    if [ ! -f "$MANIFEST_FILE" ]; then
        log_error "外部脚本清单不存在: $MANIFEST_FILE"
        exit 1
    fi

    mkdir -p "$EXTERNAL_DIR" "$BACKUP_ROOT"

    local backup_dir="$BACKUP_ROOT/$(date +%Y%m%d_%H%M%S)"
    if [ -d "$EXTERNAL_DIR" ] && find "$EXTERNAL_DIR" -type f -name '*.sh' | grep -q .; then
        mkdir -p "$backup_dir"
        cp -a "$EXTERNAL_DIR"/. "$backup_dir"/
        log_success "已备份现有外部脚本到: $backup_dir"
    else
        log_info "当前没有可备份的外部脚本。"
    fi

    local failed=0
    while IFS='|' read -r filename url description; do
        case "$filename" in
            ""|\#*) continue ;;
        esac

        local target="$EXTERNAL_DIR/$filename"
        local tmp="$target.tmp"

        log_info "更新 $filename - $description"

        if download_file "$url" "$tmp"; then
            if [ -s "$tmp" ]; then
                mv "$tmp" "$target"
                chmod +x "$target"
                log_success "已下载: $filename"
            else
                rm -f "$tmp"
                log_error "下载结果为空: $url"
                failed=$((failed + 1))
            fi
        else
            rm -f "$tmp"
            log_error "下载失败: $url"
            failed=$((failed + 1))
        fi
    done < "$MANIFEST_FILE"

    if [ "$failed" -gt 0 ]; then
        log_error "外部脚本更新完成，但有 $failed 个失败。"
        exit 1
    fi

    log_success "外部脚本已全部更新到: $EXTERNAL_DIR"
}

main "$@"
