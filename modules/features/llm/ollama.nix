{
  flake.modules.nixos.llm = {
    services.ollama = {
      enable = true;
    };
  };
}
