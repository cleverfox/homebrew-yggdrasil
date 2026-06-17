# homebrew-yggdrasil

A [Homebrew](https://brew.sh) tap for [yggdrasil-ng](https://github.com/cleverfox/yggdrasil-ng),
the Rust port of the Yggdrasil mesh networking daemon.

## Install

```sh
brew tap cleverfox/yggdrasil
brew install yggdrasil-ng
```

This installs the `yggdrasil` binary (so `yggdrasil getPeers` works). It
**conflicts with** the classic (Go) `yggdrasil` from homebrew-core — installing
one blocks the other. If you have classic yggdrasil, remove it first:

```sh
brew uninstall yggdrasil
```

### Run it as a service (autostart + restart)

yggdrasil-ng needs root for the TUN device and routing, so start it as a
system service:

```sh
sudo brew services start yggdrasil-ng     # start now + at boot, restart on crash
sudo brew services restart yggdrasil-ng    # after editing the config
sudo brew services stop yggdrasil-ng
```

Config lives at `$(brew --prefix)/etc/yggdrasil/yggdrasil.toml` (generated on
first install with a fresh identity). Edit it to add peers
(https://publicpeers.neilalexander.dev), then restart. Logs go to
`$(brew --prefix)/var/log/yggdrasil-ng.log`.

### Bleeding edge

```sh
brew install --HEAD cleverfox/yggdrasil/yggdrasil-ng
```

## Maintaining (for the tap owner)

This tap builds from source, so **no Apple Developer account, code signing or
notarization is required** — Homebrew compiles on the user's machine.

On a new upstream release:

1. Tag and push `vX.Y.Z` in the `yggdrasil-ng` repo (its release workflow can
   build the .deb/.msi/.pkg artifacts).
2. Update this formula's stable `url` + `sha256`:
   ```sh
   ./update-formula.sh X.Y.Z
   git commit -am "yggdrasil-ng X.Y.Z" && git push
   ```

`brew test-bot` runs on every push/PR via `.github/workflows/tests.yml` to
audit and test-build the formula.
