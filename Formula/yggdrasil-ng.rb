class YggdrasilNg < Formula
  desc "Yggdrasil mesh networking daemon (Rust port)"
  homepage "https://github.com/cleverfox/yggdrasil-ng"
  url "https://github.com/cleverfox/yggdrasil-ng/archive/refs/tags/v0.1.6-cf.tar.gz"
  sha256 "5e82eda034b31f0b7bc3138c1c479ba8c485e23e47037ccf86b5c7e9c4803c88"
  license "MPL-2.0"
  head "https://github.com/cleverfox/yggdrasil-ng.git", branch: "cf/transportsv2"

  depends_on "rust" => :build

  # Installs a `yggdrasil` binary, so it cannot coexist with the classic (Go)
  # yggdrasil from homebrew-core. Installing either blocks the other.
  conflicts_with "yggdrasil", because: "both install a `yggdrasil` binary"

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/yggdrasil")
  end

  def post_install
    (etc/"yggdrasil").mkpath
    conf = etc/"yggdrasil/yggdrasil.toml"
    # Generate a default config (with a fresh identity) on first install.
    system bin/"yggdrasil", "--genconf=#{conf}" unless conf.exist?
  end

  service do
    run [opt_bin/"yggdrasil", "--config", etc/"yggdrasil/yggdrasil.toml",
         "--loglevel", "info"]
    keep_alive true
    # The TUN device and routing table require root, so run as a system
    # LaunchDaemon (started via `sudo brew services start`).
    require_root true
    log_path var/"log/yggdrasil.log"
    error_log_path var/"log/yggdrasil.log"
  end

  def caveats
    <<~EOS
      yggdrasil-ng installs the `yggdrasil` binary. It needs root for the TUN
      device and routing, so start it with:
        sudo brew services start yggdrasil-ng

      Config file:
        #{etc}/yggdrasil/yggdrasil.toml
      Edit it to add peers (https://publicpeers.neilalexander.dev), then restart:
        sudo brew services restart yggdrasil-ng

      Logs: #{var}/log/yggdrasil.log
    EOS
  end

  test do
    assert_match "yggdrasil", shell_output("#{bin}/yggdrasil --version")
    # Generating a config should produce a private key line.
    assert_match "private_key", shell_output("#{bin}/yggdrasil --genconf")
  end
end
