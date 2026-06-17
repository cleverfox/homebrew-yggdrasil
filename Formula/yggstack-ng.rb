class YggstackNg < Formula
  desc "Yggstack-compatible userspace mode for Yggdrasil-ng (SOCKS proxy)"
  homepage "https://github.com/cleverfox/yggstack-ng"
  # yggstack-ng pulls Yggdrasil-ng in as a git submodule, which GitHub source
  # tarballs do NOT include. Use the git strategy (tag + revision) so Homebrew
  # clones submodules; the placeholders below are filled by update-formula.sh
  # after you push a tag:  ./update-formula.sh yggstack-ng <version>
  url "https://github.com/cleverfox/yggstack-ng.git",
      tag:      "v0.1.0-cf",
      revision: "0000000000000000000000000000000000000000"
  license "MPL-2.0"
  head "https://github.com/cleverfox/yggstack-ng.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/yggstack")
  end

  def caveats
    <<~EOS
      yggstack is a userspace Yggdrasil node — it needs no TUN device and no root.
      It exposes a SOCKS proxy instead. Example:
        yggstack --autoconf --socks 127.0.0.1:1080
      See `yggstack --help` for all options.
    EOS
  end

  test do
    assert_match(/\d/, shell_output("#{bin}/yggstack --version"))
  end
end
