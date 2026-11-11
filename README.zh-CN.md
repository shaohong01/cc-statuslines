# cc-statuslines

[繁體中文](README.md) | **简体中文** | [English](README.en.md) | [日本語](README.ja.md)

Claude Code 的自定义 status line 样式集。用一个交互式安装程序列出所有样式，在你的终端里直接预览，选好就装。

```
 Opus  xhigh   412k / 1.0M · 41%
└─ model + effort ─┘ └─ context 用量 ─┘
```

## 环境要求

- [Claude Code](https://code.claude.com/docs/en/statusline)
- `jq`（macOS：`brew install jq`）
- 支持 24 位真彩色的终端
- Nerd Font（可选，圆角胶囊需要；没有的话可以改用方角）

## 安装

```bash
gh repo clone shaohong01/cc-statuslines ~/.cc-statuslines
~/.cc-statuslines/install.sh --lang zh-CN
```

安装程序会列出所有样式和实际的彩色预览，输入编号即可完成安装。重新打开 Claude Code session 后生效。

也可以跳过菜单，直接指定样式：

```bash
~/.cc-statuslines/install.sh pills-duo
```

## 样式

| 样式 | 说明 |
|---|---|
| `pills-duo` | 双色胶囊：model 与 effort 合并成一颗，context 用量单独一颗。effort 与 context 按等级和用量在绿、黄、红之间变色 |

## 命令

| 命令 | 作用 |
|---|---|
| `install.sh` | 交互式菜单：选择样式、切换语言、移除 |
| `install.sh <样式>` | 直接安装或切换到指定样式 |
| `install.sh --list` | 列出所有样式与预览 |
| `install.sh --preview <样式>` | 预览该样式在各种状态下的效果 |
| `install.sh --uninstall` | 移除 status line 设置 |
| `install.sh --lang <语言>` | 切换安装程序的语言：`zh-TW`（默认）、`zh-CN`、`en`、`ja` |

## 个人设置

安装时会创建 `~/.claude/statusline.conf`。调整都写在这里，更新仓库时不会被覆盖。

| 设置 | 默认值 | 说明 |
|---|---|---|
| `ROUND` | `1` | `1` 是圆角胶囊（需要 Nerd Font）；`0` 是方角色块 |
| `JOIN` | `round` | model 与 effort 的交界。`round` 是圆弧叠合；`flat` 是直切分色 |
| `WARN` | `50` | context 用量达到这个百分比时变黄 |
| `CRIT` | `80` | context 用量达到这个百分比时变红 |

修改后保存，status line 下次刷新时就会生效。

## 更新

```bash
git -C ~/.cc-statuslines pull
```

安装的是指向仓库的链接，所以 pull 之后就是最新版，不用重新安装。

## 安装程序做了什么

- 把 `~/.claude/statusline.sh` 建成链接，指向你选的样式。
- 在 `~/.claude/settings.json` 写入 `statusLine` 设置，其他设置原样保留。
- 修改前先把 `settings.json` 备份为 `settings.json.bak-<时间>`。
- 如果你原来有自己的 `statusline.sh`，会改名为 `statusline.sh.bak-<时间>` 保留下来。

移除时只会去掉链接和 `statusLine` 设置，备份文件与 `statusline.conf` 都会保留。

## 新增样式

1. 创建 `styles/<名称>/statusline.sh`。脚本从 stdin 读取 Claude Code 传入的 JSON，把要显示的内容输出到 stdout。
2. 创建 `styles/<名称>/style.meta`，每种语言一行说明（`zh-TW=`、`zh-CN=`、`en=`、`ja=`）。
3. 运行 `test/run.sh`，确认在每份模拟数据下都能正常输出。
4. 在四份 README 的样式表里各加一行。

安装菜单会自动扫描 `styles/`，不需要修改 `install.sh`。

## 常见问题

**胶囊两端出现方框或问号。** 终端的字体没有 Nerd Font 符号。换成 Nerd Font，或在 `statusline.conf` 里把 `ROUND` 设为 `0`。

**颜色不对。** 终端不支持 24 位真彩色。请换用支持的终端。

**context 显示 0。** 新 session 或刚执行完 `/compact` 时还没有用量数据，下一次响应后就会出现。

**没有 effort 那一段。** 当前的模型不支持 effort 参数，这时只会显示 model。
