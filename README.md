# WeChatMulti-macOS
一个适用于 macOS 的轻量级 WeChat 双开/多开脚本工具，支持 微信 4.x 及以上版本，帮助用户在 Mac 上同时登录多个微信账号。通过简单的 shell 脚本，你可以一键实现 微信双开，批量创建多个独立的 WeChat 副本，支持自动修改 Bundle ID、重新签名，并提供 自动重建副本 功能，解决每次微信更新后的重复操作问题。无论你是需要 个人微信与工作微信分开使用，还是想要测试 多个账号同时运行，本项目都能为你提供高效的 macOS 微信多开解决方案。



### 简介（英文版）

**WeChatMulti-macOS**
 A lightweight shell script for macOS that allows you to run multiple instances of WeChat (dual or more).
 It supports WeChat **v4.x+** and above, works with the latest macOS versions, and provides:

- 🚀 One-click dual launch (`auto` mode)
- 📦 Multi-instance support (`multi N` mode)
- 🔄 Auto rebuild after WeChat update (`rebuild` mode)
- 🛠 Simple manual clone instructions included

⚠️ Disclaimer: This project is for **educational and research purposes only**. Use at your own risk.

------

### 简介（中文版）

**WeChatMulti-macOS**
 这是一个轻量级的 **macOS 微信双开/多开工具脚本**，支持 **WeChat 4.x 及以上版本**。

功能特点：

- 🚀 一键双开（`auto` 模式）
- 📦 多开支持，可创建多个副本（`multi N` 模式）
- 🔄 微信更新后自动重建副本（`rebuild` 模式）
- 🛠 同时提供手动操作教程，简单易懂

⚠️ **免责声明**：本项目仅供学习与研究使用，请自行评估风险。

------



# macOS 双开/多开微信完整使用教程（支持 4.X 及以上版本）


---

## 一、准备工作
1. 确保系统为 **macOS**，并已正确安装官方微信（路径：`/Applications/WeChat.app`）。
2. 确认系统中具备以下工具：
   - `ditto`
   - `codesign`
   - `xattr`
   - `/usr/libexec/PlistBuddy`
3. 打开终端（Terminal），确保拥有 `sudo` 权限。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/376ef533a0f8424fb372c36f5e1f0491.png)



---

## 二、一键双开脚本（推荐方法）

 
> ⚠️ **免责声明**
> 本教程及脚本仅供学习和研究使用，方法来源于网络。请自行评估风险与适用性。若因操作导致系统异常、微信账号异常或其他损失，均由使用者本人承担，与本文作者无关。

---

### 终端操作｜创建脚本文件

我们需要先新建一个脚本文件，把前面给出的 `wechat-2.sh` 代码保存进去。

### 1. 新建文件

在终端中输入：

```bash
cd ~
touch wechat-2.sh
```

这样就在用户主目录下新建了一个 `wechat-2.sh` 文件。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e754b6baf5b34af2b7ee0fe24c79f46d.png)


---

### 2. 打开文件进行编辑

你可以用以下几种方法打开文件：




#### 方法1：用文本编辑器（推荐）

如果你习惯图形界面，可以用系统自带的 **TextEdit**：

```bash
open -e wechat-2.sh
```

把脚本粘贴进去，然后保存即可。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0bb415a392754d868bdf7798c5d73bc8.png)

#### 方法2：用 VS Code（如果已安装）

```bash
code wechat-2.sh
```
#### 方法3：用终端内置编辑器 nano

```bash
nano wechat-2.sh
```

* 复制我提供的脚本内容，粘贴进去；
* 粘贴完成后，按下 `Ctrl + O` 保存，然后回车；
* 按 `Ctrl + X` 退出。
---

### 3. 赋予执行权限

保存文件后，需要让脚本有运行权限：

```bash
chmod +x wechat-2.sh
```

这样 `wechat-2.sh` 就变成了可执行文件。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2fad88233506407db29e3cb40d9c826f.png)

---

### 4. 运行脚本

* **第一次运行（自动复制+双开）**

  ```bash
  sudo ./wechat-2.sh auto --force
  ```

  系统会提示输入管理员密码，请输入你的 Mac 密码（输入时不会显示）。
  
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f153482e3931453da4a9bfbbb82f3536.png)


* **多开运行（生成多个小绿书副本）**

  ```bash
  sudo ./wechat-2.sh multi 3 --force
  ```

  会自动生成：小绿书1、小绿书2、小绿书3。
  
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7f3b1752a2b04fc2819ed4c24ec74cf2.png)


* **更新后重建副本**

  ```bash
  sudo ./wechat-2.sh rebuild --force
  ```

* **关闭所有微信进程**

  ```bash
  sudo ./wechat-2.sh kill
  ```

---

👉 总结一下操作步骤：

1. `touch wechat-2.sh` 新建文件
2. `nano wechat-2.sh` 或 `open -e wechat-2.sh` 编辑脚本
3. `chmod +x wechat-2.sh` 添加运行权限
4. `sudo ./wechat-2.sh auto --force` 执行

 

 

---

## 三、完整脚本（支持双开、多开、更新后重建）

> 以下脚本包含 **multi 多开** 与 **rebuild 重建副本** 功能。

```bash
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
```

---

## 四、手动操作流程（可选）

  如果你只想多开 1 次，可以手动操作：

1. **复制应用**

   ```bash
   sudo cp -R /Applications/WeChat.app /Applications/小绿书.app
   ```

2. **修改应用唯一标识符**

   ```bash
   sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier net.maclub.wechat" /Applications/小绿书.app/Contents/Info.plist
   ```

3. **重新签名应用**

   ```bash
   sudo codesign --force --deep --sign - /Applications/小绿书.app
   ```

4. **验证结果**
    打开 Finder > 应用程序，若能看到 `小绿书.app`（图标可能灰色或正常），即可双开。

------

 

## 五、多开操作（创建多个副本）

```bash
# 创建3个副本：小绿书1、小绿书2、小绿书3
sudo ./wechat-2.sh multi 3 --force
```

---

## 六、更新后自动重建副本

### 为什么需要重建？

* 微信每次更新后，`/Applications/WeChat.app` 会被覆盖；
* 之前生成的副本可能失效或无法正常启动；
* 使用 `rebuild` 模式，可以**自动检测所有小绿书副本并重新克隆**。

### 使用方法

```bash
# 一键重建已存在的所有副本
sudo ./wechat-2.sh rebuild --force
```

### 效果

* 脚本会自动找到 `/Applications/` 下所有 `小绿书N.app`；
* 删除旧副本并重新复制新版微信；
* 重新生成 `Bundle ID` 并签名；
* 保持原来的命名（小绿书1、小绿书2…）。

---

## 七、总结

* **双开**：适合 2 个账号同时使用；
* **多开**：通过 `multi` 参数创建多个副本，实现无限多开；
* **更新后重建**：使用 `rebuild` 一键重建所有副本，免去升级后的手动操作。

---

 
