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
            echo "مدير الحزم غير معتمد"
            exit 1
            ;;
    esac
}

# تابع لتحديث إعدادات Bash و Zsh
update_shell_config() {
    local shell_config_file=$1
    local shell_type=$2
    
    case $shell_type in
        bash)
            local config_line="# إعدادات $TOOL_NAME\npowerline-daemon -q\nPOWERLINE_BASH_CONTINUATION=1\nPOWERLINE_BASH_SELECT=1\n. /usr/share/powerline/bindings/bash/powerline.sh"
            ;;
        zsh)
            local config_line="# إعدادات $TOOL_NAME\npowerline-daemon -q\n. /usr/share/powerline/bindings/zsh/powerline.zsh"
            ;;
        fish)
            local config_line="# إعدادات $TOOL_NAME\nset fish_function_path \$fish_function_path \"/usr/share/powerline/bindings/fish\"\nsource /usr/share/powerline/bindings/fish/powerline-setup.fish\npowerline-setup"
            ;;
    esac

    if ! grep -q "powerline" "$shell_config_file"; then
        # إنشاء المجلد إذا كان غير موجود (لـ Fish)
        mkdir -p "$(dirname "$shell_config_file")"
        echo -e "\n$config_line" >> "$shell_config_file"
        echo "تم تحديث $shell_config_file بإعدادات $TOOL_NAME"
        return 0
    else
        echo "$shell_config_file بالفعل يحتوي على إعدادات $TOOL_NAME"
        return 1
    fi
}

# تابع لتحديث الطرفية مباشرة
refresh_shell() {
    local shell_type=$1
    local config_updated=$2
    
    if [ "$config_updated" -eq 0 ]; then
        echo "جاري تحديث الطرفية مباشرة..."
        
        case $shell_type in
            bash)
                # تشغيل powerline-daemon وتحميل الإعدادات
                powerline-daemon -q
                source /usr/share/powerline/bindings/bash/powerline.sh
                ;;
            zsh)
                # تشغيل powerline-daemon وتحميل الإعدادات
                powerline-daemon -q
                source /usr/share/powerline/bindings/zsh/powerline.zsh
                ;;
            fish)
                # تحديث إعدادات Fish
                set fish_function_path $fish_function_path "/usr/share/powerline/bindings/fish"
                source /usr/share/powerline/bindings/fish/powerline-setup.fish
                powerline-setup
                ;;
        esac
        
        echo "✅ تم تحديث الطرفية بنجاح - يمكنك رؤية التغييرات فوراً!"
    else
        echo "ℹ️  تم اكتشاف إعدادات سابقة - يرجى إعادة فتح الطرفية أو تشغيل الأمر المناسب لشل الخاص بك"
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
current_shell=""
config_updated=0

case $SHELL in
    *bash*)
        update_shell_config "$HOME/.bashrc" "bash"
        config_updated=$?
        current_shell="bash"
        ;;
    *zsh*)
        update_shell_config "$HOME/.zshrc" "zsh"
        config_updated=$?
        current_shell="zsh"
        ;;
    *fish*)
        update_shell_config "$HOME/.config/fish/config.fish" "fish"
        config_updated=$?
        current_shell="fish"
        ;;
    *)
        echo "نوع الطرفية غير مدعوم."
        exit 1
        ;;
esac

# تحديث الطرفية مباشرة
refresh_shell "$current_shell" "$config_updated"

echo "تثبيت $TOOL_NAME وإعدادات الطرفية تمت بنجاح بواسطة $DEV_NAME."
echo "🌟 يمكنك الآن الاستمتاع بـ Powerline في طرفيتك مباشرة!"
