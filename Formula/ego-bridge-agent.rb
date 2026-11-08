class EgoBridgeAgent < Formula
  desc "Linux service and CLI for the ego bridge remote browser"
  homepage "https://github.com/gwen0x4c3/ego-bridge"
  url "https://github.com/gwen0x4c3/ego-bridge/releases/download/v2.3.0/ego-bridge-v2.3.0-linux.tar.gz"
  sha256 "76cb0c1fbd119ea818079a46d6b8ffdac7a2ef299cd4dc73af207eca82e5b5e8"
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
