cask "ego-bridge" do
  arch arm: "arm64", intel: "x86_64"

  version "2.4.0"
  sha256 arm: "55e4c6b023c717a1128e896af99373b0dbc9bfa341fecb657dca6915fc744a1f",
         intel: "314f2d1a0819a4db2d9cbb0df47dbb92f43a77f0e24c316bac21bafa0762a0b7"

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
