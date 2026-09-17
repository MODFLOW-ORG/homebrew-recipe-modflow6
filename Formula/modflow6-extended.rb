class Modflow6Extended < Formula
  desc "USGS modular hydrologic model (extended build with MPI, PETSc, and NetCDF)"
  homepage "https://www.usgs.gov/software/modflow-6-usgs-modular-hydrologic-model"
  url "https://github.com/MODFLOW-ORG/modflow6/archive/refs/tags/6.8.0.tar.gz"
  sha256 "e031d000eeacba00238421379e98dbcb1d4928fedaa4d9665d92932eb33dbaed"
  license "CC0-1.0"
  head "https://github.com/MODFLOW-ORG/modflow6.git", branch: "develop"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "gcc" # for gfortran
  depends_on "modflow-org/recipe-modflow6/petsc@3.22"
  depends_on "netcdf"
  depends_on "netcdf-fortran"
  depends_on "open-mpi"

  conflicts_with "modflow6", because: "both install `mf6`, `zbud6`, and `libmf6`"

  def install
    system "meson", "setup", "build", "-Dextended=true", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    # two-model simulation used by the test block
    pkgshare.install ".mf6minsim" => "test"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mf6 --version") if build.stable?

    # parallel run with one model on each process
    (testpath/"parallel").mkpath
    cp_r pkgshare/"test/.", testpath/"parallel"
    cd testpath/"parallel" do
      system formula_opt_bin("open-mpi")/"mpiexec", "--oversubscribe", "-n", "2", bin/"mf6", "-p"
      assert_match "Normal termination of simulation", File.read("mfsim.p0.lst")
    end

    # serial run with structured NetCDF output
    (testpath/"netcdf").mkpath
    cp_r pkgshare/"test/.", testpath/"netcdf"
    cd testpath/"netcdf" do
      inreplace "leftmodel.nam", "BEGIN options\n", "BEGIN options\n  NETCDF_STRUCTURED FILEOUT leftmodel.nc\n"
      system bin/"mf6"
      assert_match "Normal termination of simulation", File.read("mfsim.lst")
      assert_match "netcdf leftmodel", shell_output("#{formula_opt_bin("netcdf")}/ncdump -h leftmodel.nc")
    end
  end
end
