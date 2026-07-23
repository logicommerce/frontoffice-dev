# Working on Windows (WSL)

On Windows this environment **must run inside WSL2 (Linux)**, not on native Windows.

The Dev Container relies on POSIX symbolic links (the `www`, `fwk`, `sdk` and `plugins` links pointing to `/local/...`). Native Windows filesystems can't provide these with the semantics the container expects, so both the **LogiCommerce Studio extension** and the **manual procedure** ([FRONTDEV.md](FRONTDEV.md)) must be run from within WSL, with the project stored in the WSL Linux filesystem.

Do this setup once; afterwards you work exactly like on Linux.

## 1. Install WSL2 + Ubuntu

In an elevated PowerShell:

```powershell
wsl --install -d Ubuntu
```

Reboot if asked, then open **Ubuntu** and create your Linux user. Verify:

```powershell
wsl -l -v
```

Ubuntu should be listed as `Running` with `VERSION 2`. Docker Desktop, if installed, also creates a `docker-desktop` distro - leave it alone; work only in `Ubuntu`.

## 2. Docker

You need a Docker engine reachable from WSL. Two options:

### Option A - Docker Engine inside WSL (recommended, no license)

Install Docker Engine directly in Ubuntu (see the [official docs](https://docs.docker.com/engine/install/ubuntu/)). Enable systemd so it starts as a service by adding to `/etc/wsl.conf`:

```ini
[boot]
systemd=true
```

Then from PowerShell run `wsl --shutdown`, reopen Ubuntu, and:

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # log out/in afterwards
docker run --rm hello-world     # should print the welcome message
```

### Option B - Docker Desktop with WSL integration

Install Docker Desktop, then in **Settings → Resources → WSL Integration** enable integration with your **Ubuntu** distro. Make sure Docker Desktop uses the **Linux** containers engine (WSL2 based).

> With Docker Desktop, start it and wait until the whale icon is green (**Engine running**) **before** opening the project in VS Code - otherwise the container tooling reports the engine as not available.

## 3. Put the project in the WSL Linux filesystem

Clone/place your `projects` folder **inside** the Ubuntu home (e.g. `~/projects`), **not** under `/mnt/c/...`. Files under `/mnt/c` are on the Windows drive and don't support the symlinks the container needs (and are much slower).

```bash
cd ~
git clone <your-repo> projects   # or create the structure described in FRONTDEV.md
```

## 4. Open the project via Remote-WSL

- Install the **WSL** extension (`ms-vscode-remote.remote-wsl`) in VS Code.
- From Ubuntu: `code ~/projects`, or in VS Code use **WSL: Open Folder in WSL…**.
- Confirm the bottom-left status bar shows **WSL: Ubuntu**.

> Do not open the project via the `\\wsl.localhost\Ubuntu\...` path from Windows - that runs VS Code locally, not connected to WSL. Always use Remote-WSL.

## 5. Continue as on Linux

Once connected to WSL with the project in the Linux filesystem, follow the normal flow:

- **Recommended:** the **LogiCommerce Studio** extension - see [README.md](README.md). On Windows the extension only works from this Remote-WSL context; its host actions are blocked on native Windows.
- **Manual:** the step-by-step in [FRONTDEV.md](FRONTDEV.md). Run `use-commerce.sh` and all shell commands from the Ubuntu terminal.

## Tips

- **Source Control not showing in VS Code:** repositories are reached through symlinks; opening any file inside a repo makes VS Code detect it.
- **Switching commerce / "Back to folder":** these reopen the project connected to WSL. If a rebuild is needed, use **Dev Containers: Rebuild Container**.
