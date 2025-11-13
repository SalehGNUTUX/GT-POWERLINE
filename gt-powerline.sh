#!/bin/bash

# اسم المطور
DEV_NAME="SalehGNUTUX"
# اسم الأداة
TOOL_NAME="GT-POWERLINE"

# تابع لاكتشاف مدير الحزم
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    else
        echo "مدير الحزم غير مدعوم"
        exit 1
    fi
}

# تابع للتحقق من تثبيت Powerline
check_powerline_installed() {
    if command -v powerline &> /dev/null; then
        echo "مكتبة Powerline مثبتة بالفعل."
        return 0
    else
        return 1
    fi
}

# تابع لتثبيت الحزم المطلوبة
install_packages() {
    local manager=$1

    case $manager in
        apt)
            sudo apt update
            sudo apt install -y powerline fonts-powerline
            ;;
        pacman)
            sudo pacman -Syu --noconfirm powerline powerline-fonts
            ;;
        dnf)
            sudo dnf install -y powerline powerline-fonts
            ;;
        yum)
            sudo yum install -y powerline powerline-fonts
            ;;
        *)
            echo "مدير الحزم غير مدعوم" 
            exit 1
            ;;
    esac
}

# تابع لتحديث إعدادات الملف
update_shell_config() {
    local shell_config_file=$1
    local config_line="# إعدادات $TOOL_NAME\npowerline-daemon -q\nPOWERLINE_BASH_CONTINUATION=1\nPOWERLINE_BASH_SELECT=1\n. /usr/share/powerline/bindings/bash/powerline.sh"

    if ! grep -q "powerline" "$shell_config_file"; then
        echo -e "\n$config_line" >> "$shell_config_file"
        echo "تم تحديث $shell_config_file بإعدادات $TOOL_NAME"
    else
        echo "$shell_config_file بالفعل يحتوي على إعدادات $TOOL_NAME"
    fi
}

# بداية السكربت
pkg_manager=$(detect_package_manager)

if check_powerline_installed; then
    read -p "هل ترغب في إعادة تثبيت Powerline؟ (y/n): " choice
    case "$choice" in
        y|Y)
            install_packages $pkg_manager
            ;;
        n|N)
            echo "لن يتم التثبيت مرة أخرى."
            exit 0
            ;;
        *)
            echo "اختيار غير صالح، سيتم إنهاء البرنامج."
            exit 1
            ;;
    esac
else
    install_packages $pkg_manager
fi

# تحديد أي طرفية يستخدمها المستخدم
case $SHELL in
    *bash*)
        update_shell_config "$HOME/.bashrc"
        ;;
    *zsh*)
        update_shell_config "$HOME/.zshrc"
        ;;
    *fish*)
        echo "ليس لدينا إعدادات لـ fish في الوقت الحالي."
        exit 1
        ;;
    *)
        echo "نوع الطرفية غير مدعوم."
        exit 1
        ;;
esac

# تحديث الطرفية بعد التثبيت
if [[ $SHELL == *"bash"* ]]; then
    source "$HOME/.bashrc"
    echo "تم تحديث الطرفية. يمكنك الآن رؤية تغييرات Powerline."
elif [[ $SHELL == *"zsh"* ]]; then
    source "$HOME/.zshrc"
    echo "تم تحديث الطرفية. يمكنك الآن رؤية تغييرات Powerline."
fi

echo "تثبيت $TOOL_NAME وإعدادات الطرفية تمت بنجاح بواسطة $DEV_NAME."
