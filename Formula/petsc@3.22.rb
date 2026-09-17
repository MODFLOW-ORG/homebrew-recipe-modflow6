class PetscAT322 < Formula
  desc "Portable, Extensible Toolkit for Scientific Computation (3.22 for MODFLOW 6)"
  homepage "https://petsc.org/"
  url "https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.22.2.tar.gz"
  sha256 "83624de0178b42d37ca1f7f905e1093556c6919fe5accd3e9f11d00a66e11256"
  license "BSD-2-Clause"

  # MODFLOW 6 does not build with PETSc 3.23 or newer, and 3.22.2 matches the
  # version used by the MODFLOW 6 pixi gcc-extended-build environment
  livecheck do
    skip "Pinned to the PETSc version used by MODFLOW 6"
  end

  keg_only :versioned_formula

  depends_on "gcc" # for gfortran
  depends_on "open-mpi"
  depends_on "openblas"

  uses_from_macos "python" => :build

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-debugging=0",
                          "--with-scalar-type=real",
                          "--with-shared-libraries=1",
                          "--with-fortran-bindings=1",
                          "--with-x=0",
                          "--CC=mpicc",
                          "--CXX=mpicxx",
                          "--F77=mpif77",
                          "--FC=mpif90",
                          "--with-blaslapack-dir=#{formula_opt_prefix("openblas")}",
                          "MAKEFLAGS=$MAKEFLAGS"

    # Avoid references to Homebrew shims (perform replacement before running `make`, or else the shim
    # paths will still end up in compiled code)
    inreplace "arch-#{OS.kernel_name.downcase}-c-opt/include/petscconf.h", "#{Superenv.shims_path}/", ""

    system "make", "all"
    system "make", "install"

    # Avoid references to Homebrew shims
    rm(lib/"petsc/conf/configure-hash")

    if OS.mac? || File.foreach("#{lib}/petsc/conf/petscvariables").any? { |l| l[Superenv.shims_path.to_s] }
      inreplace lib/"petsc/conf/petscvariables", "#{Superenv.shims_path}/", ""
    end

    # Avoid references to cellar paths
    gcc = Formula["gcc"]
    open_mpi = Formula["open-mpi"]
    inreplace (lib/"pkgconfig").glob("*.pc") do |s|
      s.gsub! prefix, opt_prefix
      s.gsub! gcc.prefix.realpath, gcc.opt_prefix
      s.gsub! open_mpi.prefix.realpath, open_mpi.opt_prefix
    end
  end

  test do
    examples = share/"petsc/examples/src/ksp/ksp/tutorials"
    flags = %W[-I#{include} -L#{lib} -lpetsc]
    flags << "-Wl,-rpath,#{lib}" if OS.linux?

    # C interface
    system "mpicc", examples/"ex1.c", "-o", "ex1", *flags
    line = shell_output("./ex1").lines.last
    assert_match(/^Norm of error .+, Iterations/, line, "Unexpected output format")
    error = line.split[3].to_f
    assert (error >= 0.0 && error < 1.0e-13), "Error norm too large"

    # Fortran interface, which MODFLOW 6 uses
    system "mpif90", examples/"ex2f.F90", "-o", "ex2f", *flags
    output = shell_output("./ex2f")
    assert_match(/Norm of error .+ iterations +\d+/, output)
    # prints "< 1.e-12" for very small norms; to_f of "<" is 0.0
    assert_operator output[/Norm of error\s+(\S+)/, 1].to_f, :<, 1.0e-4, "Error norm too large"
  end
end
