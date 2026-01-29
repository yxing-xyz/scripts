{
  pkgs,
}:
let
  trzsz = pkgs.buildGoModule rec {
    pname = "trzsz-go";
    version = "v1.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "trzsz";
      repo = "trzsz-go";
      rev = "v1.2.0";
      hash = "sha256-CokZAXT61UKSsKnzE5mPMdAZecGX/8mgDkG4yDSat5M==";
    };

    # 1. 必须提供 vendorHash 而不能是 null
    # 2. 既然设置了 proxyVendor = true，Nix 会下载依赖并计算这个哈希
    #vendorHash = pkgs.lib.fakeHash; # 先用这个占位，运行后根据报错修改
    vendorHash = "sha256-xodZBTZaCOQiT2G7KzM7XlsSq8K8nnBAvL3uH5OCC5s=";
    proxyVendor = true;

    preBuild = ''
      rm -rf vendor
    '';

    env = {
      CGO_ENABLED = "0";
    };

    subPackages = [
      "cmd/trz"
      "cmd/tsz"
      "cmd/trzsz"
    ];

    meta = with pkgs.lib; {
      description = "trzsz is a simple file transfer tool, similar to rz / sz";
      homepage = "https://github.com/trzsz/trzsz-go";
      license = licenses.mit;
    };
  };
in
trzsz
