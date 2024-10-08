{appimageTools, fetchurl}:

let
  name = "actual-budget";
  version = "24.10.1";
  src = fetchurl {
    url = "https://github.com/actualbudget/actual/releases/download/v${version}/Actual-linux.AppImage";
    sha256 = "sha256-Xqb2wECLy3um8yR7MHnVvEdjRko1waHTpkzi18CgarE=";
  };
  appimageContents = appimageTools.extractType2 {inherit name src;};
  in
appimageTools.wrapType2 {
  inherit name version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/desktop-electron.desktop $out/share/applications/actual.desktop
    install -m 444 -D ${appimageContents}/desktop-electron.png $out/share/icons/hicolor/512x512/apps/actual.png
    sed -i -e 's/desktop-electron/actual/g' $out/share/applications/actual.desktop
    sed -i -e 's/Exec=.*/Exec=actual-budget/g' $out/share/applications/actual.desktop
    '';
}
