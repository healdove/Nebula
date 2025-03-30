load("@toolchains//byond.bzl", "ByondToolchainInfo")

ByondProjectInfo = provider(fields = {
  "dmb_file": provider_field(Artifact),
  "rsc_file": provider_field(Artifact),
})

def _byond_project_impl(ctx: AnalysisContext):
  tc = ctx.attrs._byond_toolchain[ByondToolchainInfo]
  base = ctx.attrs.dme.basename
  if ctx.attrs.dme.extension == ".dme":
    base = base[:-4]
  dmb_out = ctx.actions.declare_output(f"{base}.dmb")
  rsc_out = ctx.actions.declare_output(f"{base}.rsc")

  symlink_map = {src.short_path: src for src in ctx.attrs.srcs + [ctx.attrs.dme]}
  symlink_dir = ctx.actions.symlinked_dir("build", symlink_map)

  args = [
    ctx.attrs._dmbuild[RunInfo],
    "--build_root", symlink_dir,
    "--dm_bin", tc.dm_compiler,
    "--dme", ctx.attrs.dme.short_path,
    "--dmb_out", dmb_out.as_output(),
    "--rsc_out", rsc_out.as_output(),
    "--",
  ]
  args.extend(ctx.attrs.build_args)

  ctx.actions.run(
    args,
    category = "byond_compile",
  )
  return [
    DefaultInfo(default_outputs = [dmb_out, rsc_out]),
    ByondProjectInfo(
      dmb_file = dmb_out,
      rsc_file = rsc_out,
    ),
  ]

byond_project = rule(
  impl = _byond_project_impl,
  attrs = {
    "dme": attrs.source(),
    "srcs": attrs.list(attrs.source()),
    "build_args": attrs.list(attrs.string(), default=[]),
    "_byond_toolchain": attrs.default_only(
      attrs.toolchain_dep(
        default = "toolchains//:byond",
        providers = [ByondToolchainInfo],
      )
    ),
    "_dmbuild": attrs.exec_dep(
      default = "//:dmbuild",
      providers = [RunInfo],
    ),
  }
)

def _ss13_dme_mappatch_impl(ctx: AnalysisContext):
  in_dme = ctx.attrs.dme
  out_dme = ctx.actions.declare_output(in_dme.basename)

  args = [
    ctx.attrs._tool[RunInfo],
    "--dme",
    in_dme,
    "--out",
    out_dme.as_output(),
  ]
  if ctx.attrs.map:
    args.extend(["--map", ctx.attrs.map])

  ctx.actions.run(args, category = "ss13_dme_mappatch")

  return [DefaultInfo(default_outputs = [out_dme])]

ss13_dme_mappatch = rule(
  impl = _ss13_dme_mappatch_impl,
  attrs = {
    "dme": attrs.source(),
    "map": attrs.string(
      default = "",
    ),
    "_tool": attrs.exec_dep(
      default = "//:dme_mappatch",
      providers = [RunInfo],
    ),
  },
)

def _ss13_test_impl(ctx: AnalysisContext):
  tc = ctx.attrs._byond_toolchain[ByondToolchainInfo]
  proj = ctx.attrs.project[ByondProjectInfo]

  symlink_map = {src.short_path: src for src in ctx.attrs.data + [proj.dmb_file, proj.rsc_file]}
  symlink_dir = ctx.actions.symlinked_dir("test_root", symlink_map)

  args = [
    ctx.attrs._tool[RunInfo],
    "--test_root", symlink_dir,
    "--dd_bin", tc.dd_server,
    "--dmb_file", proj.dmb_file.short_path,
    "--rsc_file", proj.rsc_file.short_path,
  ]

  return [
    DefaultInfo(),
    RunInfo(args),
    ExternalRunnerTestInfo(
      type = "ss13_test",
      command = args,
    ),
  ]


ss13_test = rule(
  impl = _ss13_test_impl,
  attrs = {
    "project": attrs.dep(
      providers = [ByondProjectInfo],
    ),
    "data": attrs.list(attrs.source()),
    "_tool": attrs.exec_dep(
      default = "//:ss13test",
      providers = [RunInfo],
    ),
    "_byond_toolchain": attrs.default_only(
      attrs.toolchain_dep(
        default = "toolchains//:byond",
        providers = [ByondToolchainInfo],
      )
    ),
  },
)