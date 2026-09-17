class Modflow6 < Formula
  desc "USGS modular hydrologic model (serial build)"
  homepage "https://www.usgs.gov/software/modflow-6-usgs-modular-hydrologic-model"
  url "https://github.com/MODFLOW-ORG/modflow6/archive/refs/tags/6.8.0.tar.gz"
  sha256 "e031d000eeacba00238421379e98dbcb1d4928fedaa4d9665d92932eb33dbaed"
  license "CC0-1.0"
  head "https://github.com/MODFLOW-ORG/modflow6.git", branch: "develop"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "gcc" # for gfortran

  def install
    # parallel and netcdf default to false, so this is the serial build
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    # mf5to6 is a separate meson project and is not reached by the top-level
    # meson.build, so it is configured, built, and installed on its own
    system "meson", "setup", "build_mf5to6", "utils/mf5to6", *std_meson_args
    system "meson", "compile", "-C", "build_mf5to6", "--verbose"
    system "meson", "install", "-C", "build_mf5to6"

    # minimal simulation used by the test block
    pkgshare.install ".mf6minsim" => "test"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mf6 --version")
    assert_path_exists bin/"zbud6"
    # mf5to6 has no --help or --version flag and prompts on stdin
    assert_path_exists bin/"mf5to6"

    cp_r pkgshare/"test/.", testpath
    system bin/"mf6"
    assert_match "Normal termination of simulation", (testpath/"mfsim.lst").read
  end
end
