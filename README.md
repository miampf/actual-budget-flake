# Actual Budgeting

A flake that adds a service and the desktop application for [Actual](https://actualbudget.org).

Import the flake by adding `inputs.actual-budget.url = "github:miampf/actual-budget-url";` and `inputs.actual-budget.inputs.nixpkgs.follows = "nixpkgs";`
to your flake. Now you can add `actual-budget.overlays.default` to your nixpkgs overlays to get access to
`pkgs.actualBudgetDesktop` and `actual-budget.nixosModules.actual-server` to your flakes `modules` if you want
access to `services.actualBudgetServer`.

## The actualBudgetServer service

Add this to your `configuration.nix` to enable the actual-server (I've written all the default options out here):

```nix
services.actualBudgetServer = {
    enable = true; # of course false by default
    port = 5006; # The port that the actual-server will listen on
    configureNginx = false; # Configure nginx with TLS encryption as a reverse proxy.
    httpOrigin = ""; # The origin that will be used by nginx, e.g. https://example.com
    uploadFileSyncLimit = 20; # Filesize limit for syncing in MB
    uploadEncryptedFileSyncLimit = 50; # Filesize limit for encrypted syncing in MB
    uploadFileLimit = 20; # general upload file limit
    dataPath = /etc/actual-data; # the data path of the actual server
};
```
