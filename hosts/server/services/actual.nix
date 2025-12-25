{
  ports,
  ...
}:
{
  enable = true;
  settings = {
    hostname = "0.0.0.0";
    port = ports.actual;
  };
}
