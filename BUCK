load("//byond.bzl", "byond_project", "ss13_dme_mappatch", "ss13_test")

genrule(
    name = "hello_world",
    out = "out.txt",
    cmd = "echo BUILT BY BUCK2> $OUT",
)

python_binary(
  name = "hello",
  main = "hello.py",
)

python_binary(
  name = "dmbuild",
  main = "build.py",
  visibility = ['PUBLIC']
)

python_binary(
  name = "dme_mappatch",
  main = "dme_mappatch.py",
  visibility = ['PUBLIC']
)

python_binary(
  name = "ss13test",
  main = "run_test.py",
  visibility = ['PUBLIC']
)

ss13_dme_mappatch(
  name = "neb_map",
  dme = "nebula.dme",
  map = "modpack_testing",
)

byond_project(
  name = "nebula",
  dme = ":neb_map",
  srcs = glob(
    [
      "code/**",
      "maps/**",
      "mods/**",
      "~code/**",
      "interface/**",
      "sound/**",
      "icons/**",
      "html/**",
      "nano/**",
    ],
  ),
  build_args = ["-DUNIT_TEST"],
)

ss13_test(
  name = "nebula_test",
  project = ":nebula",
  data = glob(
    [
      "config/**",
      "data/**",
      "maps/**",
      "mods/**",
      "nano/**",
    ],
  ),
)