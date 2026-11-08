#!/usr/bin/env python3
"""Render this tap from an upstream Release manifest; no external Python deps."""
import argparse
from pathlib import Path
import re
import urllib.request

CASK = r'''cask "ego-bridge" do
  arch arm: "arm64", intel: "x86_64"

  version "@VERSION@"
  sha256 arm: "@ARM@",
         intel: "@INTEL@"

  url "https://github.com/gwen0x4c3/ego-bridge/releases/download/v#{version}/ego-bridge-v#{version}-macos-#{arch}.zip"
  name "ego bridge"
  desc "Use your Mac browser from remote AI agents"
  homepage "https://github.com/gwen0x4c3/ego-bridge"

  depends_on formula: "python@3.13"
  depends_on macos: ">= :ventura"

  app "EgoBridge.app"
  command_wrapper "ego-bridge",
                  executable: "#{HOMEBREW_PREFIX}/opt/python@3.13/bin/python3.13",
                  args: ["-B", "#{appdir}/EgoBridge.app/Contents/Resources/ego-bridge"]

  uninstall quit: "app.ego-bridge.EgoBridge"

  caveats <<~EOS
    Install the official ego-lite browser separately and finish its onboarding.
    Open EgoBridge.app, then pair with the code from the Linux service.
    The App is ad-hoc signed and is not Developer ID notarized.
  EOS
end
'''
FORMULA = r'''class EgoBridgeAgent < Formula
  desc "Linux service and CLI for the ego bridge remote browser"
  homepage "https://github.com/gwen0x4c3/ego-bridge"
  url "https://github.com/gwen0x4c3/ego-bridge/releases/download/v@VERSION@/ego-bridge-v@VERSION@-linux.tar.gz"
  sha256 "@LINUX@"
  license "MIT"

  depends_on :linux
  depends_on "openssl@3"
  depends_on "python@3.13"

  def install
    libexec.install "linux/ego_agent_service.py", "linux/ego-browser"
    (bin/"ego-browser").write <<~SH
      #!/bin/sh
      exec "#{Formula["python@3.13"].opt_bin}/python3.13" "#{libexec}/ego-browser" "$@"
    SH
    (bin/"ego-agent-service").write <<~SH
      #!/bin/sh
      export PATH="#{Formula["openssl@3"].opt_bin}:$PATH"
      exec "#{Formula["python@3.13"].opt_bin}/python3.13" "#{libexec}/ego_agent_service.py" "$@"
    SH
    chmod 0755, bin/"ego-browser"
    chmod 0755, bin/"ego-agent-service"
    doc.install "README.md", "docs/SECURITY.md"
  end

  service do
    run [opt_bin/"ego-agent-service"]
    keep_alive true
    log_path var/"log/ego-bridge.log"
    error_log_path var/"log/ego-bridge-error.log"
  end

  test do
    assert_match "usage:", shell_output("#{bin}/ego-agent-service --help")
    assert_path_exists bin/"ego-browser"
  end
end
'''


def fetch(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'ego-bridge-homebrew-tap'})
    with urllib.request.urlopen(req, timeout=60) as result:
        return result.read().decode()


def main():
    import json
    ap = argparse.ArgumentParser()
    ap.add_argument('--tag')
    ap.add_argument('--checksums', type=Path)
    ap.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1])
    args = ap.parse_args()
    tag = args.tag or json.loads(fetch('https://api.github.com/repos/gwen0x4c3/ego-bridge/releases/latest'))['tag_name']
    if not re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+', tag):
        raise SystemExit('Unsupported release tag: ' + tag)
    text = args.checksums.read_text() if args.checksums else fetch(
        'https://github.com/gwen0x4c3/ego-bridge/releases/download/' + tag + '/SHA256SUMS')
    hashes = {}
    for line in text.splitlines():
        parts = line.split()
        if len(parts) == 2 and re.fullmatch(r'[a-f0-9]{64}', parts[0]):
            hashes[parts[1]] = parts[0]
    values = {'VERSION': tag[1:], 'ARM': hashes['ego-bridge-' + tag + '-macos-arm64.zip'],
              'INTEL': hashes['ego-bridge-' + tag + '-macos-x86_64.zip'],
              'LINUX': hashes['ego-bridge-' + tag + '-linux.tar.gz']}
    for relative, template in [('Casks/ego-bridge.rb', CASK), ('Formula/ego-bridge-agent.rb', FORMULA)]:
        for name, value in values.items():
            template = template.replace('@' + name + '@', value)
        path = args.output / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(template)
    print('Updated tap to ' + tag)


if __name__ == '__main__':
    main()
