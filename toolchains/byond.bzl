ByondToolchainInfo = provider(fields = {
  "dm_compiler": provider_field(RunInfo),
  "dd_server": provider_field(RunInfo),
})

def _system_byond_toolchain_impl(ctx):
  return [
    DefaultInfo(),
    ByondToolchainInfo(
      dm_compiler = RunInfo(args = ["DreamMaker"]),
      dd_server = RunInfo(args = ["DreamDaemon"]),
    ),
  ]

system_byond_toolchain = rule(
  impl = _system_byond_toolchain_impl,
  attrs = {},
  is_toolchain_rule = True,
)