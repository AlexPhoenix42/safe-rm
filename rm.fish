function rm
    set red (set_color red)
    set yellow (set_color yellow)
    set reset (set_color normal)

    set opts
    set targets
    set bulk_mode 0
    set force_mode 0
    set help_mode 0
    set trash_mode 0

    for arg in $argv
        if string match -qr '^-' -- $arg
            if string match -qr '^--' -- $arg
                switch $arg
                    case "--all"
                        set bulk_mode 1
                    case "--force"
                        set force_mode 1
                        set opts $opts --force
                    case "--help"
                        set help_mode 1
                    case "--trash"
                        set trash_mode 1
                    case "*"
                        set opts $opts $arg
                end
            else
                set flags (string split '' (string replace -r '^-' '' -- $arg))
                for flag in $flags
                    switch $flag
                        case "a"
                            set bulk_mode 1
                        case "f"
                            set force_mode 1
                            set opts $opts -f
                        case "r"
                            set opts $opts -r
                        case "h"
                            set help_mode 1
                        case "t"
                            set trash_mode 1
                        case "*"
                            set opts $opts -$flag
                    end
                end
            end
        else
            set targets $targets $arg
        end
    end

    # Help mode
    if test $help_mode -eq 1
        	echo
echo -e "\e]8;;https://github.com/AlexPhoenix42\e\\Powered by $BLUEgithub.com/AlexPhoenix42$RESET 🌈🚀\e]8;;\e\\"
echo
        echo "Usage: rm [options] files..."
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
        return
    end

    # Safety net: block dangerous paths
    for file in $targets
        if test "$file" = "/" -o "$file" = "~"
            echo "$yellow⚠️ Refusing to delete critical path: '$red$file$reset'$yellow.$reset"
            return 1
        end
    end

    # Extra safety: block rm -rf /* when in root
    if test (pwd) = "/"
        for file in $targets
            if string match -q "/*" -- $file
                echo "$yellow⚠️ Refusing to delete everything under root ('$red$file$reset').$reset"
                return 1
            end
        end
    end

    # Ensure Trash directory exists
    if test $trash_mode -eq 1
        mkdir -p ~/.Trash
    end

    # Bulk confirmation mode
    if test $bulk_mode -eq 1
        if test $force_mode -eq 1
            for file in $targets
                if test $trash_mode -eq 1
                    mv $file ~/.Trash/
                    echo "🗑️ Moved '$red$file$reset' to Trash"
                else
                    command rm $opts $file
                    echo "✅ Deleted '$red$file$reset'"
                end
            end
            return
        end

        read -P "⚠️ 🗑️  Really delete ALL (count $targets) files? [Y/n] " bulk_confirm
        if test "$bulk_confirm" = "Y"
            for file in $targets
                if test -d "$file" -a $trash_mode -eq 0
                    if not contains -- -r $opts
                        echo "$yellow⚠️ '$red$file$reset' is a directory. Use 'rm -r $file'.$reset"
                        continue
                    end
                end
                if test $trash_mode -eq 1
                    mv $file ~/.Trash/
                    echo "🗑️ Moved '$red$file$reset' to Trash"
                else
                    command rm $opts $file
                    echo "✅ Deleted '$red$file$reset'"
                end
            end
        else
            echo "❌ Skipped all files"
        end
        return
    end

    # Default: per-file confirmation
    for file in $targets
        if test $force_mode -eq 1
            if test $trash_mode -eq 1
                mv $file ~/.Trash/
                echo "🗑️ Moved '$red$file$reset' to Trash"
            else
                command rm $opts $file
                echo "✅ Deleted '$red$file$reset'"
            end
            continue
        end

        read -P "⚠️ 🗑️  Really delete '$red$file$reset'? [Y/n] " confirm

        if test -z "$confirm"
            echo "❌ Skipped '$red$file$reset' (default)"
            continue
        end

        switch $confirm
            case Y
                if test -d "$file" -a $trash_mode -eq 0
                    if not contains -- -r $opts
                        echo "$yellow⚠️ '$red$file$reset' is a directory. Use 'rm -r $file'.$reset"
                        continue
                    end
                end
                if test $trash_mode -eq 1
                    mv $file ~/.Trash/
                    echo "🗑️ Moved '$red$file$reset' to Trash"
                else
                    command rm $opts $file
                    echo "✅ Deleted '$red$file$reset'"
                end
            case '*'
                echo "❌ Skipped '$red$file$reset'"
        end
    end
end
