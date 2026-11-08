# Homebrew packages by gwen0x4c3

Prebuilt [ego bridge](https://github.com/gwen0x4c3/ego-bridge) packages. No Swift build is required.

## Mac: App + control CLI

```bash
brew install --cask gwen0x4c3/tap/ego-bridge
open -a EgoBridge
```

This installs EgoBridge.app, the `ego-bridge` command and Python. The official ego-lite
browser remains a separate prerequisite. The App is ad-hoc signed, not notarized.
Quit an older running App before upgrading or migrating from a source installation.

## Linux: agent service + browser CLI

```bash
brew install gwen0x4c3/tap/ego-bridge-agent
brew services start gwen0x4c3/tap/ego-bridge-agent
ego-browser pair
```

Includes Python/OpenSSL dependencies. The service uses the current user's existing
`~/.config/ego-bridge` credentials. macOS must be able to reach Linux TCP port 3325.
Choose either Homebrew services or the standalone installer to manage the service.

## Updates

```bash
brew update
brew upgrade --cask gwen0x4c3/tap/ego-bridge
# Linux:
brew upgrade gwen0x4c3/tap/ego-bridge-agent
brew services restart gwen0x4c3/tap/ego-bridge-agent
```

A scheduled workflow reads the upstream public Release and regenerates version/hash
entries every six hours. Maintainers can also run the Sync workflow manually. No
cross-repository personal access token is stored in this repository.
