{
lib,
config,
...
}:

with lib;

let 
  cfg = config.services.actualBudgetServer;
in
{
  options = {
    services.actualBudgetServer = {
      enable = mkEnableOption "actualBudgetServer";
      port = mkOption {
        type = types.ints.between 0 65535;
        default = 5006;
        description = mdDoc ''
          Define the port that the actual-server will expose.
        '';
      };
      configureNginx = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
          Configure an NGINX reverse proxy.
        '';
      };
      httpOrigin = mkOption {
        type = types.str;
        default = "";
        description = mdDoc ''
          Your server url (e.g. https://actualbudget.example.com).
        '';
      };
      uploadFileSyncLimit = mkOption {
        type = types.int;
        default = 20;
        description = mdDoc ''
          Set the file size limit of synced files in MB.
        '';
      };
      uploadEncryptedFileSyncLimit = mkOption {
        type = types.int;
        default = 50;
        description = mdDoc ''
          Set the file size limit of encrypted synced files in MB.
        '';
      };
      uploadFileLimit = mkOption {
        type = types.int;
        default = 20;
        description = mdDoc ''
          Set the file size limit of uploaded files in MB.
        '';
      };
      dataPath = mkOption {
        type = types.path;
        default = /etc/actual-data;
        description = mdDoc ''
          Set the data path.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.tmpfiles.rules = ["d ${builtins.toString cfg.dataPath} 1666 root root -"];
      virtualisation.docker.enable = true;
      virtualisation.oci-containers.containers."actual-server" = {
        autoStart = true;
        image = "docker.io/actualbudget/actual-server:latest";
        ports = ["${builtins.toString cfg.port}:5006"];
        environment = {
          ACTUAL_PORT = "${builtins.toString cfg.port}";
          ACTUAL_UPLOAD_FILE_SYNC_SIZE_LIMIT_MB = "${builtins.toString cfg.uploadFileSyncLimit}";
          ACTUAL_UPLOAD_SYNC_ENCRYPTED_FILE_SYNC_SIZE_LIMIT_MB = "${builtins.toString cfg.uploadEncryptedFileSyncLimit}";
          ACTUAL_UPLOAD_FILE_SIZE_LIMIT_MB = "${builtins.toString cfg.uploadFileLimit}";
        };
        volumes = ["${builtins.toString cfg.dataPath}:/data"];
      };
    }
    (mkIf cfg.configureNginx {
      assertions = [
        {
          assertion = strings.hasPrefix "https://" cfg.httpOrigin;
          message = "services.actualBudgetServer.httpOrigin must start with https:// when services.actualBudgetServer.configureNginx is enabled.";
        }
      ];

      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        virtualHosts = {
          "${strings.removePrefix "https://" cfg.httpOrigin}" = {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
              proxyWebsockets = true;
            };
          };
        };
      };
    })
  ]);
}
