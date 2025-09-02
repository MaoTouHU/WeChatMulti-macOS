#!/bin/bash
# macOS WeChat Multi Instance Script
# Usage:
#   sudo ./wechat-2.sh auto --force
#   sudo ./wechat-2.sh multi 3 --force   # 多开3个副本
#   sudo ./wechat-2.sh rebuild --force   # 更新后自动重建所有副本

set -euo pipefail

# 颜色
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# 默认路径
WECHAT_APP="/Applications/WeChat.app"
DEST_DIR="/Applications"
BASE_APP_NAME="小绿书"
FORCE=0

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || { echo -e "${RED}缺少命令: $1${NC}"; exit 1; }
}
for cmd in ditto codesign xattr /usr/libexec/PlistBuddy; do require_cmd "$cmd"; done

check_wechat() {
    if [ ! -d "$WECHAT_APP" ]; then
        echo -e "${RED}未找到微信: $WECHAT_APP${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ 检测到微信已安装${NC}"
}

remove_app() {
    local dest="$DEST_DIR/$1"
    if [ -d "$dest" ]; then
        if [ $FORCE -eq 1 ]; then
            sudo rm -rf "$dest"
        else
            read -p "是否删除并重新创建 $1? (y/n): " yn
            [[ $yn =~ ^[Yy]$ ]] && sudo rm -rf "$dest"
        fi
    fi
}

copy_wechat() {
    local app_name=$1
    sudo ditto "$WECHAT_APP" "$DEST_DIR/$app_name"
}

modify_bundle_id() {
    local app_name=$1
    local info_plist="$DEST_DIR/$app_name/Contents/Info.plist"
    local new_id="com.tencent.xinWeChat.dual.$RANDOM"
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $new_id" "$info_plist"
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $app_name" "$info_plist" || true
}

resign_app() {
    local app_name=$1
    local dest="$DEST_DIR/$app_name"
    sudo rm -rf "$dest/Contents/_CodeSignature" || true
    sudo xattr -dr com.apple.quarantine "$dest" || true
    sudo codesign --force --deep --sign - --timestamp=none "$dest"
}

start_apps() {
    shift
    for app_name in "$@"; do open -n "$DEST_DIR/$app_name"; sleep 1; done
}

kill_wechat() {
    pkill -f "WeChat" || true
}

# 查找已存在的小绿书副本
list_existing_apps() {
    ls "$DEST_DIR" | grep "^$BASE_APP_NAME[0-9]*\.app$" || true
}

main() {
    case "${1:-}" in
        setup)
            check_wechat
            remove_app "${BASE_APP_NAME}.app"
            copy_wechat "${BASE_APP_NAME}.app"
            modify_bundle_id "${BASE_APP_NAME}.app"
            resign_app "${BASE_APP_NAME}.app"
            ;;
        start)
            start_apps "WeChat.app" "${BASE_APP_NAME}.app"
            ;;
        auto)
            check_wechat
            remove_app "${BASE_APP_NAME}.app"
            copy_wechat "${BASE_APP_NAME}.app"
            modify_bundle_id "${BASE_APP_NAME}.app"
            resign_app "${BASE_APP_NAME}.app"
            start_apps "WeChat.app" "${BASE_APP_NAME}.app"
            ;;
        multi)
            local count=${2:-2}
            check_wechat
            for i in $(seq 1 "$count"); do
                local app_name="${BASE_APP_NAME}${i}.app"
                remove_app "$app_name"
                copy_wechat "$app_name"
                modify_bundle_id "$app_name"
                resign_app "$app_name"
            done
            start_apps $(for i in $(seq 1 "$count"); do echo "${BASE_APP_NAME}${i}.app"; done)
            ;;
        rebuild)
            check_wechat
            echo -e "${BLUE}检测到系统更新或微信更新，正在重建副本...${NC}"
            local apps=$(list_existing_apps)
            for app_name in $apps; do
                echo -e "${YELLOW}重建 $app_name ...${NC}"
                remove_app "$app_name"
                copy_wechat "$app_name"
                modify_bundle_id "$app_name"
                resign_app "$app_name"
            done
            echo -e "${GREEN}✓ 所有副本已重新生成${NC}"
            ;;
        -k|kill)
            kill_wechat
            ;;
        -h|--help|"")
            echo "用法: $0 {setup|start|auto|multi N|rebuild|kill} [--force]"
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            exit 1
            ;;
    esac
}

for arg in "$@"; do [[ $arg == "--force" ]] && FORCE=1; done
main "$@"
