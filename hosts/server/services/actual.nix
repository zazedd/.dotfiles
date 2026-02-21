{
  config,
  ...
}:
{
  enable = true;
  settings = {
    hostname = "0.0.0.0";
    port = config.my.reverse-proxy.actual.port;
  };
}
