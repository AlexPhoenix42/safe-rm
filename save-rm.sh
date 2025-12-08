# ========================================================================
# alias rm="~/bin/safe-rm.sh"
# ========================================================================
#!/usr/bin/env bash

red=$(tput setaf 1)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

bulk_mode=0
force_mode=0
help_mode=0
trash_mode=0
opts=()
targets=()

# Parse arguments
for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
        case "$arg" in
            --all) bulk_mode=1 ;;
            --force) force_mode=1; opts+=("--force") ;;
            --help) help_mode=1 ;;
            --trash) trash_mode=1 ;;
            *) opts+=("$arg") ;;
        esac
    elif [[ "$arg" == -* ]]; then
        flags="${arg#-}"
        for (( i=0; i<${#flags}; i++ )); do
            flag="${flags:$i:1}"
            case "$flag" in
                a) bulk_mode=1 ;;
                f) force_mode=1; opts+=("-f") ;;
                r) opts+=("-r") ;;
                h) help_mode=1 ;;
                t) trash_mode=1 ;;
                *) opts+=("-$flag") ;;
            esac
        done
    else
        targets+=("$arg")
    fi
done

# Help mode
if [[ $help_mode -eq 1 ]]; then
    echo
    echo -e "\e]8;;https://github.com/AlexPhoenix42\e\\Powered by $BLUEgithub.com/AlexPhoenix42$RESET 🌈🚀\e]8;;\e\\"
    echo
    echo "Usage: safe-rm [options] files..."
    echo ""
    echo "Options:"
    echo "  -a, --all     Bulk confirm once for all files"
    echo "  -f, --force   Skip confirmation (delete immediately)"
    echo "  -r            Recursively delete directories"
    echo "  -t, --trash   Move files to ~/.Trash instead of deleting"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Safety:"
    echo "  Refuses dangerous commands like 'rm -rf /', 'rm -rf ~', or 'rm -rf /*' at root"
    exit 0
fi

# Safety net
for file in "${targets[@]}"; do
    if [[ "$file" == "/" || "$file" == "~" ]]; then
        echo "${yellow}⚠️ Refusing to delete critical path: '${red}$file${reset}'${yellow}.${reset}"
        exit 1
    fi
done

if [[ "$(pwd)" == "/" ]]; then
    for file in "${targets[@]}"; do
        if [[ "$file" == /* ]]; then
            echo "${yellow}⚠️ Refusing to delete everything under root ('${red}$file${reset}').${reset}"
            exit 1
        fi
    done
fi

# Ensure Trash exists
if [[ $trash_mode -eq 1 ]]; then
    mkdir -p ~/.Trash
fi

# Bulk mode
if [[ $bulk_mode -eq 1 ]]; then
    if [[ $force_mode -eq 1 ]]; then
        for file in "${targets[@]}"; do
            if [[ $trash_mode -eq 1 ]]; then
                mv "$file" ~/.Trash/
                echo "🗑️ Moved '${red}$file${reset}' to Trash"
            else
                rm "${opts[@]}" "$file"
                echo "✅ Deleted '${red}$file${reset}'"
            fi
        done
        exit 0
    fi

    read -p "⚠️ 🗑️  Really delete ALL ${#targets[@]} files? [Y/n] " bulk_confirm
    if [[ "$bulk_confirm" == "Y" ]]; then
        for file in "${targets[@]}"; do
            if [[ -d "$file" && $trash_mode -eq 0 && ! " ${opts[*]} " =~ " -r " ]]; then
                echo "${yellow}⚠️ '${red}$file${reset}' is a directory. Use 'rm -r $file'.${reset}"
                continue
            fi
            if [[ $trash_mode -eq 1 ]]; then
                mv "$file" ~/.Trash/
                echo "🗑️ Moved '${red}$file${reset}' to Trash"
            else
                rm "${opts[@]}" "$file"
                echo "✅ Deleted '${red}$file${reset}'"
            fi
        done
    else
        echo "❌ Skipped all files"
    fi
    exit 0
fi

# Default: per-file confirmation
for file in "${targets[@]}"; do
    if [[ $force_mode -eq 1 ]]; then
        if [[ $trash_mode -eq 1 ]]; then
            mv "$file" ~/.Trash/
            echo "🗑️ Moved '${red}$file${reset}' to Trash"
        else
            rm "${opts[@]}" "$file"
            echo "✅ Deleted '${red}$file${reset}'"
        fi
        continue
    fi

    read -p "⚠️ 🗑️  Really delete '${red}$file${reset}'? [Y/n] " confirm
    if [[ -z "$confirm" ]]; then
        echo "❌ Skipped '${red}$file${reset}' (default)"
        continue
    fi

    if [[ "$confirm" == "Y" ]]; then
        if [[ -d "$file" && $trash_mode -eq 0 && ! " ${opts[*]} " =~ " -r " ]]; then
            echo "${yellow}⚠️ '${red}$file${reset}' is a directory. Use 'rm -r $file'.${reset}"
            continue
        fi
        if [[ $trash_mode -eq 1 ]]; then
            mv "$file" ~/.Trash/
            echo "🗑️ Moved '${red}$file${reset}' to Trash"
        else
            rm "${opts[@]}" "$file"
            echo "✅ Deleted '${red}$file${reset}'"
        fi
    else
        echo "❌ Skipped '${red}$file${reset}'"
    fi
done
# ========================================================================
