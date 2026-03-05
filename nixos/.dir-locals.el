((nix-ts-mode . (
    (eglot-workspace-configuration . (
        :nixd (
            :nixpkgs (:expr "import (builtins.getFlake \"/home/x/workspace/github/scripts/nixos/\").inputs.nixpkgs { }")
            :options (
                :nixos (:expr "(builtins.getFlake \"/home/x/workspace/github/scripts/nixos/\").nixosConfigurations.x-laptop.options")
                :home-manager (:expr "(builtins.getFlake \"/home/x/workspace/github/scripts/nixos/\").nixosConfigurations.x-laptop.options.home-manager.users.type.getSubOptions [ ]")
            )
            :eval (
                :target (
                    :args []
                    :installable "/home/x/workspace/github/scripts/nixos/#nixosConfigurations.x-laptop.config.system.build.toplevel"
                )
            )
        )
    ))
)))
