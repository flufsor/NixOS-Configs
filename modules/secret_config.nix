{ self, config, ... }:
{
  age.rekey = {
    inherit (self.rekeyConfig) masterIdentities extraEncryptionPubkeys;
    hostPubkey = builtins.readFile "${self}/hosts/${config.networking.hostName}/host.pub";
    storageMode = "local";
    generatedSecretsDir = self.outPath + "/secrets/_generated/${config.networking.hostName}";
    localStorageDir = self.outPath + "/secrets/_rekeyed/${config.networking.hostName}";
  };
}
