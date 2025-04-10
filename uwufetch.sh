#!/bin/bash

# Конфигурационный файл
CONFIG_FILE="$HOME/.config/uwufetch.conf"

# Функция для проверки времени суток
is_daytime() {
    current_hour=$(date +%H)
    if (( current_hour >= 6 && current_hour < 18 )); then
        return 0  # день (6:00-17:59)
    else
        return 1  # ночь (18:00-5:59)
    fi
}

# Функция для проверки первого запуска
check_first_run() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "\033[1;36mЭто первый запуск uwufetch! (* ^ ω ^)\033[0m"
        read -p "Хотите запускать uwufetch при открытии терминала? [Y/n] " answer
        
        case ${answer,,} in
            y|yes|"")
                add_to_shellrc
                ;;
            *)
                echo "Вы можете добавить это позже, отредактировав ~/.bashrc или ~/.zshrc"
                ;;
        esac
        
        # Создаем конфиг файл
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo "first_run=false" > "$CONFIG_FILE"
    fi
}

# Функция для добавления в автозагрузку терминала
add_to_shellrc() {
    # Определяем какой shell используется
    current_shell=$(basename "$SHELL")
    
    case $current_shell in
        bash)
            shellrc="$HOME/.bashrc"
            ;;
        zsh)
            shellrc="$HOME/.zshrc"
            ;;
        *)
            shellrc="$HOME/.bashrc"
            ;;
    esac
    
    # Добавляем запуск uwufetch
    if ! grep -q "uwufetch" "$shellrc"; then
        echo -e "\n# Запуск uwufetch при старте терминала" >> "$shellrc"
        echo "uwufetch" >> "$shellrc"
        echo -e "\033[1;32mДобавлено в $shellrc! UwU\033[0m"
    else
        echo -e "\033[1;33mАвтозапуск уже настроен! (´･ω･\`)\033[0m"
    fi
}

# Функция для получения информации о системе
get_system_info() {
    # Основная информация
    OS=$(source /etc/os-release; echo $PRETTY_NAME 2>/dev/null || echo "Unknown OS")
    KERNEL=$(uname -r)
    UPTIME=$(uptime -p | sed 's/up //')
    SHELL=$(basename "$SHELL")
    SHELL_VER=$("$SHELL" --version | head -n1)
    CPU=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs 2>/dev/null || echo "Unknown CPU")
    GPU=$(lspci | grep -i "vga\|3d\|display" | cut -d':' -f3 | xargs | head -n1 2>/dev/null || echo "Unknown GPU")
    MEM_USED=$(free -m | awk '/Mem:/ {printf "%.0fMiB", $3}' 2>/dev/null || echo "?")
    MEM_TOTAL=$(free -m | awk '/Mem:/ {printf "%.0fMiB", $2}' 2>/dev/null || echo "?")
    
    # Получаем имя хоста
    HOSTNAME=$(uname -n 2>/dev/null || echo "unknown-host")
}

# Функция для отображения дневного котика
display_day_cat() {
    get_system_info
    
    # Цвета
    PURPLE='\033[1;35m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[1;36m'
    BLUE='\033[1;34m'
    RESET='\033[0m'
    
    # Дневной котик ASCII
    echo -e "${PURPLE}                   /\_/\           ${RESET}    ${GREEN}$(whoami)@${HOSTNAME}${RESET}"
    echo -e "${PURPLE}                  ( o.o )          ${RESET}    ${GREEN}------------------${RESET}"
    echo -e "${PURPLE}                  > ^ <            ${RESET}    ${YELLOW}OS:${RESET} $OS"
    echo -e "${PURPLE}                                   ${RESET}    ${YELLOW}Kernel:${RESET} $KERNEL"
    echo -e "${PURPLE}       /\___/\                     ${RESET}    ${YELLOW}Uptime:${RESET} $UPTIME"
    echo -e "${PURPLE}      /       \                    ${RESET}    ${YELLOW}Shell:${RESET} $SHELL ${SHELL_VER%% *}"
    echo -e "${PURPLE}     /  0   0  \                   ${RESET}    ${YELLOW}CPU:${RESET} $CPU"
    echo -e "${PURPLE}    ( ==  ^  == )                  ${RESET}    ${YELLOW}GPU:${RESET} $GPU"
    echo -e "${PURPLE}     )         (                   ${RESET}    ${YELLOW}Memory:${RESET} $MEM_USED / $MEM_TOTAL"
    echo -e "${PURPLE}    (           )                  ${RESET}"
    echo -e "${PURPLE}   ( (  )   (  ) )                 ${RESET}    ${CYAN}Nyarch btw (* ^ ω ^)${RESET}"
    echo -e "${PURPLE}  (__(__)___(__)__)                ${RESET}    ${BLUE}By @miqyz UwU${RESET}"
}

# Функция для отображения ночного котика
display_night_cat() {
    get_system_info
    
    # Цвета
    BLUE='\033[1;34m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[1;36m'
    RESET='\033[0m'
    
    # Исправленный спящий котик ASCII
    echo -e "${BLUE}                                            ${RESET}    ${GREEN}$(whoami)@${HOSTNAME}${RESET}"
    echo -e "${BLUE}                                            ${RESET}    ${GREEN}------------------${RESET}"
    echo -e "${BLUE}                                            ${RESET}    ${YELLOW}OS:${RESET} $OS"
    echo -e "${BLUE}                |\      _,,,---,,_          ${RESET}    ${YELLOW}Kernel:${RESET} $KERNEL"
    echo -e "${BLUE}         ZZZzz /, \`.-' \`'    -.  ;-;;,_     ${RESET}    ${YELLOW}Uptime:${RESET} $UPTIME"
    echo -e "${BLUE}              |,4-  ) )-,_. ,\ (  \`'-'      ${RESET}    ${YELLOW}Shell:${RESET} $SHELL ${SHELL_VER%% *}"
    echo -e "${BLUE}             '---''(_/--'  \`-'\_)           ${RESET}    ${YELLOW}CPU:${RESET} $CPU"
    echo -e "${BLUE} - Zzz... Не мешай спать... (－ω－) Zzz...  ${RESET}    ${YELLOW}GPU:${RESET} $GPU"
    echo -e "${BLUE}   - И я тебе советую закрыть терминал!     ${RESET}    ${YELLOW}Memory:${RESET} $MEM_USED / $MEM_TOTAL"
    echo -e "${BLUE}                                            ${RESET}    ${CYAN}Nyarch btw (－ω－) Zzz... - Даже я сплю..${RESET}"
    echo -e "${BLUE}                                            ${RESET}    ${BLUE}By @miqyz -_- -Zzz...${RESET}"
}

# Проверяем зависимости
check_dependencies() {
    local missing=()
    
    if ! command -v lscpu &> /dev/null; then
        missing+=("util-linux (для lscpu)")
    fi
    
    if ! command -v lspci &> /dev/null; then
        missing+=("pciutils (для lspci)")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "\033[1;33mВнимание: Некоторые функции могут не работать!\033[0m"
        echo "Установите недостающие пакеты:"
        for pkg in "${missing[@]}"; do
            echo " - $pkg"
        done
        echo -e "\nДля Debian/Ubuntu: sudo apt install ${missing[*]%% *}"
        echo "Для Arch: sudo pacman -S ${missing[*]%% *}"
        echo -e "\nПродолжаем без них... (´･ω･\`)\n"
    fi
}

# Основная функция
main() {
    check_first_run
    check_dependencies
    
    if is_daytime; then
        display_day_cat
    else
        display_night_cat
    fi
}

main "$@"
