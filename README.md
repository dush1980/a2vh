**a2vh** (Apache2 Virtual Host Manager) is a Bash script that simplifies creating and deleting Apache virtual hosts on Debian-based systems. It automates configuration file generation, site enabling/disabling, and Apache restarts — all from a single command.

---

## 📂 Files

- `virtualhost.sh` – The main executable script.
- `virtualhost.hlp` – Help screen displayed when using `-h`.
- `addhost_windows.hlp` – Instructions for updating the Windows `hosts` file.

---

## ⚙️ Requirements

- Apache2 must be installed.
- Must be run as `root` (or via `sudo`).
- Debian-based system (Ubuntu, etc.).
- Bash shell environment.

---

## 🚀 Installation

Make the script executable:

```bash
chmod +x a2vh.sh
```

(Optional) Rename and move to your path for global use:

```bash
sudo mv a2vh.sh /usr/local/bin/a2vh
```

---

## 🧰 Usage

```bash
sudo ./a2vh.sh <domain> [options]
```

### Options

- `-p <path>` — Set the root directory for the domain.
- `-d` — Delete the virtual host instead of creating.
- `-h` — Show help (from `virtualhost.hlp`).

---

## ✅ Examples

### Create a new virtual host

```bash
sudo ./a2vh.sh example.local -p /var/www/example
```

This will:
- Generate a new config file at `/etc/apache2/sites-available/example.local.conf`
- Enable the site with `a2ensite`
- Restart Apache
- Display Windows `hosts` file help

### Delete a virtual host

```bash
sudo ./a2vh.sh example.local -d
```

This will:
- Disable the site with `a2dissite`
- Prompt to remove or keep the config file
- Restart Apache
- Show Windows `hosts` file instructions

---

## 📝 Notes

- The first parameter must be the domain name (e.g., `myproject.local`).
- Ensure your domain is mapped in your system’s `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows).
- If a config file already exists, the script will prompt you to back it up or keep it.

---

## 🔒 Permissions

You must run the script as root:

```bash
sudo ./a2vh.sh ...
```

If not, the script will exit with a warning.

---

## 📃 License

MIT License. Use, modify, share.

---

## 👨‍💻 Author

Dushmantha Walakulpola — Feel free to contribute or fork!
