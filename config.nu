# config.nu
#
# Installed by:
# version = "0.107.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# -- Basic Settings --
$env.config.buffer_editor = "neovide"
$env.config.show_banner = false
$env.config.edit_mode = "vi"
# $env.config.table.mode = "psql"
$env.config.rm.always_trash = true
$env.config.completions.algorithm = "fuzzy"
$env.PROMPT_INDICATOR_VI_INSERT = "❯ "
$env.PROMPT_INDICATOR_VI_NORMAL = "❮ "
$env.config.color_config.bool = {|x| if $x { 'light_green' } else { 'light_red' } }

# -- alias --
alias ls = ls -d
alias la = ls -a
alias nvide = neovide
alias vim = neovide
alias lg = lazygit

# -- StarShip --
$env.STARSHIP_SHELL = "nu"
def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# -- Key Bindings --
# $env.config.keybindings ++= [
#     {
#         name: insert_last_token
#         modifier: alt
#         keycode: char_.
#         mode: [emacs vi_normal vi_insert]
#         event: [
#             { edit: InsertString, value: "!$" } # 插入上一個命令的最後一個參數
#         ]
#     }
# ]

# -- Plugins --

const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ...$NU_PLUGIN_DIRS
]

# -- zoxide --
source ~/.zoxide.nu

# -- yazi --
def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

# --- Gemini CLI Helper ---
# 用法: g 你的任務描述
# 範例: g 列出所有 .toml 檔案
def g [...prompt_parts: string] {
    # 將所有傳入的參數組合成一個字串
    let prompt = ($prompt_parts | str join " ")
    if ($prompt | is-empty) {
        print "錯誤：請提供要執行的任務。"
        return
    }

    let full_prompt = ($"產生一個 Nushell 指令來完成以下任務：" | append $prompt | append "。只輸出指令本身，不要包含任何說明、解釋或程式碼區塊標記。") | str join " "
    echo $full_prompt | gemini
}
