class PostgresqlPlpyAT17 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v17.3/postgresql-17.3.tar.bz2"
  sha256 "13c18b35bf67a97bd639925fc581db7fd2aae4d3548eac39fcdb8da74ace2bea"
  license "PostgreSQL"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(17(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://www.conversence.com/bottles"
    sha256 cellar: :any, arm64_sequoia: "aace809b7c7e78acbc95f3bc966cf340c49e8535bddb89595550cfc49407781c"
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2029-11-08", because: :unsupported

  depends_on "postgresql@17"
  depends_on "python@3.12"

  def install
    # Modify Makefile to link macOS binaries using Cellar path. Otherwise, binaries are linked
    # using #{HOMEBREW_PREFIX}/lib path set during ./configure, which will cause audit failures
    # for broken linkage as the paths are not created until post-install step.

    inreplace "src/Makefile.shlib", "-install_name '$(libdir)/", "-install_name '#{lib}/postgresql/"

    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"
    ENV.prepend "PYTHON", "#{HOMEBREW_PREFIX}/opt/python@3.12/bin/python3.12"

    # Fix 'libintl.h' file not found for extensions
    if OS.mac?
      ENV.prepend "LDFLAGS", "-L#{Formula["gettext"].opt_lib} -L#{Formula["krb5"].opt_lib}"
      ENV.prepend "CPPFLAGS", "-I#{Formula["gettext"].opt_include} -I#{Formula["krb5"].opt_include}"
    end

    args = %W[
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql@17
      --includedir=#{HOMEBREW_PREFIX}/include/postgresql@17
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --enable-nls
      --enable-thread-safety
      --with-gssapi
      --with-icu
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-lz4
      --with-zstd
      --with-openssl
      --with-pam
      --with-python
      --with-uuid=e2fs
    ]
    args << "--with-extra-version= (#{tap.user})" if tap
    args += %w[--with-bonjour --with-tcl] if OS.mac?

    # PostgreSQL by default uses xcodebuild internally to determine this,
    # which does not work on CLT-only installs.
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if OS.mac? && MacOS.sdk_root_needed?

    system "./configure", *args, *std_configure_args(libdir: HOMEBREW_PREFIX/"lib/postgresql@17")
    system "make"

    # We use an unversioned `postgresql` subdirectory rather than `#{name}` so that the
    # post-installed symlinks can use non-conflicting `#{name}` and be retained on `brew unlink`.
    # Removing symlinks may break PostgreSQL as its binaries expect paths from ./configure step.
    chdir "src/pl/plpython" do
      system "make", "install", "datadir=#{share}/postgresql",
                                    "libdir=#{lib}/postgresql",
                                    "includedir=#{include}/postgresql"
    end
    chdir "contrib/hstore_plpython" do
      system "make", "install", "datadir=#{share}/postgresql",
                                    "libdir=#{lib}/postgresql",
                                    "includedir=#{include}/postgresql"
    end
    chdir "contrib/ltree_plpython" do
      system "make", "install", "datadir=#{share}/postgresql",
                                    "libdir=#{lib}/postgresql",
                                    "includedir=#{include}/postgresql"
    end
    chdir "contrib/jsonb_plpython" do
      system "make", "install", "datadir=#{share}/postgresql",
                                    "libdir=#{lib}/postgresql",
                                    "includedir=#{include}/postgresql"
    end
  end

  def post_install

    # Manually link files from keg to non-conflicting versioned directories in HOMEBREW_PREFIX.
    %w[include lib share locale].each do |dir|
      dst_dir = HOMEBREW_PREFIX/dir/"postgresql@17"
      src_dir = prefix/dir/"postgresql"
      src_dir.find do |src|
        dst = dst_dir/src.relative_path_from(src_dir)

        # Retain existing real directories for extensions if directory structure matches
        next if dst.directory? && !dst.symlink? && src.directory? && !src.symlink?

        rm_r(dst) if dst.exist? || dst.symlink?
        if src.symlink? || src.file?
          Find.prune if src.basename.to_s == ".DS_Store"
          dst.parent.install_symlink src
        elsif src.directory?
          dst.mkpath
        end
      end
    end
  end

  def postgresql_datadir
    var/name
  end


end
