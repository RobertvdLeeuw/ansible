# NixOS \-\> Debian Migration

**IMPORTANT: BACKUP THE MINECRAFT WORLD \+ MODS**  
	**Waybar modules too (also: vibe code the other modules: server up, calendar, email, bluetooth)**

Some universal .env file for API keys, IP addresses, etc.

Tools:  
	Ansible for package management  
		Flesh out structure (mostly package grouping)  
		Symlinks for dotfiles  
   [https://github.com/topgrade-rs/topgrade](https://github.com/topgrade-rs/topgrade)  
  https://github.com/linuxmint/timeshift  
   

Commands:  
	“search \<name\>” to find package in all pakmans  
	Somehow link that to:

- “try \<match\>” \-\> Distrobox, apt/flatpak/snap install package

		    ideally snapshot/cache so we don’t spin up an entire Debian every time

- “Add \<match\>” \-\> Install, put in ansible in right location.

	“fromwhere \<name\>” to find installed matches (like search name)

- "update" \-\> topgrade \+ ansible-playbook system.yml   
- "status" \-\> Show what's installed vs what should be (ansible \--check)   
- "clean" \-\> Remove orphaned packages, clean caches   
- "backup" \-\> Trigger backup script  
- "installed" \-\> List all packages from all sources with source info   
- "conflicts" \-\> Check for version conflicts across package managers   
- "deps \<package\>" \-\> Show dependency tree

NVIM:  
	[https://github.com/olimorris/codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)  
[https://github.com/monkoose/neocodeium](https://github.com/monkoose/neocodeium)  
https://github.com/rockerBOO/awesome-neovim?tab=readme-ov-file\#completion  
	Some project finder that’s easy to open and faster than zoxide cd project \-\> nvim wherever/[main.py](http://main.py)  
	Harpoon  
	After harpoon try: try splits  
	  
	Autocomp merging: just use AI comp for now, see if I miss LSP comp.

Appendix/later, homelab iteration:

- NAS instead of nextcloud  
- Keep bitwarden  
- N8n  
- Coding LLM  
- Postgres playground


Software:

- Steam  
- Brave (try min browser)  
- Teams  
- Spotify  
- Dolphin  
- Alacritty  
- Nextcloud  
- Sway  
- KDE (minimal, )  
- Discord  
- Loupe  
- Prismlauncher (minecraft)  
- Docker \+ compose  
- bat  
- Navi  
- Notification thing because electron exists

Terminal software:

- Zoxide  
- Dust  
- Bat  
- Fdfind