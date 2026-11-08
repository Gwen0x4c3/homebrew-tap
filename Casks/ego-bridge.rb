cask "ego-bridge" do
  arch arm: "arm64", intel: "x86_64"

  version "2.4.1"
  sha256 arm: "8f2b6522a5976230bb9275ada07d4461cc687d4ecdc71ebdc157ba7e65222451",
         intel: "4d0b196a02730b9e1b254d0a370f13ae2a7f63f8c0448b6ceebc20bc80f5dfd5"

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
