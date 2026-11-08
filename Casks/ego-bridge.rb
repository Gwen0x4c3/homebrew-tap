cask "ego-bridge" do
  arch arm: "arm64", intel: "x86_64"

  version "2.3.0"
  sha256 arm: "02a5f588391217536d1ba59c1080e9adfef837814ea6a5d06ecc9fc0505ba2c1",
         intel: "cf80b343dff19431ccbd4a6d77d682a81035cd8a71d6460e13973c33aec4517a"

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
