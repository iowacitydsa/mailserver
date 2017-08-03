{ config, lib, ... }:

let
  acmeCallbackPort = 80;
  adminMail = "tech@iowacitydsa.org";
in

{
  services.mlmmj =
    { enable = true;
      listDomain = "iowacitydsa.org";
      mailLists = [ "exec" "members" "announce" ];
    };

  services.postfix =
    { extraAliases = builtins.readFile ./aliases;
      # Private email aliases are stored in this file,
      # included an alias for $adminMail

      hostname = "mail.iowacitydsa.org";
      destination = [ "iowacitydsa.org" ];
      domain = "iowacitydsa.org";
      enableSubmission = true;
      origin = "mail.iowacitydsa.org";
      postmasterAlias = adminMail;
      relayDomains = [ "iowacitydsa.org" ];
      sslCACert = "/var/lib/acme/mail.iowacitydsa.org/account_key.json";
      sslKey = "/var/lib/acme/mail.iowacitydsa.org/key.pem";
      submissionOptions.smtpd_hard_error_limit = "2";
    };

  services.nginx.virtualHosts."mail.iowacitydsa.org" =
    { enableACME = true;
    };

  security.acme.certs."mail.iowacitydsa.org".email = adminMail;

  networking.firewall.allowedTCPPorts = [ 25 587 acmeCallbackPort ];
}
