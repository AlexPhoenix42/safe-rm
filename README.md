# 🗑️ safe-rm

A safer, smarter replacement for `rm` written in Bash (with a Fish shell version available too).  
This wrapper adds **confirmation prompts, bulk delete options, trash mode, and safety nets** to prevent catastrophic mistakes like `rm -rf /`.

This can save from heart-breaks! custom 'rm' with prompt before deletion! Disclaimer: No guarantees! Use at your own risk!

---

## ✨ Features

- **Per-file confirmation** by default
- **Bulk confirmation** with `-a` / `--all` (one prompt for all files)
- **Force mode** with `-f` / `--force` (skip confirmations entirely)
- **Recursive deletion** with `-r` (required for directories)
- **Trash mode** with `-t` / `--trash` (moves files to `~/.Trash` instead of deleting)
- **Help option** with `-h` / `--help` (prints usage guide)
- **Safety net**:
  - Refuses `rm -rf /`
  - Refuses `rm -rf ~`
  - Refuses `rm -rf /*` when run from root

---

## 🚀 Installation

Clone the repo and make the script executable:

```bash
git clone https://github.com/AlexPhoenix42/safe-rm.git
cd safe-rm
chmod +x safe-rm.sh
```

Add it to your `$PATH` (e.g., `~/bin`):

```bash
mkdir -p ~/bin
cp safe-rm.sh ~/bin/
```

---

## ⚡ Usage

```bash
safe-rm file1 file2          # prompts one by one
safe-rm -a file1 file2       # bulk confirm once for all files
safe-rm -fa file1 file2      # delete all immediately (no confirmation)
safe-rm -ra dir1 dir2        # bulk confirm, recursive deletion
safe-rm -rfa dir1 dir2       # recursive delete, no confirmation
safe-rm -t file1 file2       # move files to ~/.Trash
safe-rm -rt dir1 dir2        # move directories to Trash (recursively)
safe-rm -h                   # show help message
```

---

## 🔒 Safety

- Refuses to delete `/`, `~`, or `/*` at root
- Directories require `-r` to avoid accidental removal
- Trash mode provides a reversible alternative to permanent deletion

---

## 🛠️ Alias (Optional)

To replace `rm` with `safe-rm` for your user account:

```bash
echo 'alias rm="~/bin/safe-rm.sh"' >> ~/.bashrc
source ~/.bashrc
```

You can still access the real `rm` with:

```bash
command rm file.txt
```

---

## 📦 Fish Shell Version

A Fish shell function is also included (`rm.fish`) with the same features.  
Copy it into `~/.config/fish/functions/rm.fish` to use inside Fish.

---

## ⚠️ Disclaimer

This script is designed to reduce risk, but **no tool can guarantee absolute safety**.  
Always double-check before deleting files.

---

## 📜 License

MIT License — feel free to use, modify, and share.
```

---
