class PostgresqlPlpyAT16 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v16.1/postgresql-16.1.tar.bz2"
  sha256 "ce3c4d85d19b0121fe0d3f8ef1fa601f71989e86f8a66f7dc3ad546dd5564fec"
  license "PostgreSQL"
  revision 2

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(16(?:\.\d+)+)/?["' >]}i)
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2028-11-09", because: :unsupported

  depends_on "postgresql@16"
  depends_on "python@3.11"

  def install
    print "#{buildpath}/stage"
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"
    ENV.prepend "PYTHON", "#{HOMEBREW_PREFIX}/opt/python@3.11/bin/python3.11"

    if OS.mac?
      # Fix 'libintl.h' file not found for extensions
      ENV.prepend "LDFLAGS", "-L#{Formula["gettext"].opt_lib}"
      ENV.prepend "CPPFLAGS", "-I#{Formula["gettext"].opt_include}"
    end

    args = std_configure_args + %W[
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql@16
      --libdir=#{HOMEBREW_PREFIX}/lib/postgresql@16
      --includedir=#{HOMEBREW_PREFIX}/include/postgresql@16
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --mandir=#{libexec}/man
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
      --with-extra-version=\ (#{tap.user})
    ]
    if OS.mac?
      args += %w[
        --with-bonjour
        --with-tcl
      ]
    end

    # PostgreSQL by default uses xcodebuild internally to determine this,
    # which does not work on CLT-only installs.
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if OS.mac? && MacOS.sdk_root_needed?

    system "./configure", *args
    system "make", "pkglibdir=#{lib}/postgresql@16",
                   "pkgincludedir=#{include}/postgresql@16",
                   "includedir_server=#{include}/postgresql@16/server"
    mkdir "stage"
    chdir "src/pl/plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}/postgresql@16",
                                      "pkglibdir=#{lib}/postgresql@16",
                                      "includedir=#{include}/postgresql@16",
                                      "pkgincludedir=#{include}/postgresql@16",
                                      "includedir_server=#{include}/postgresql@16/server",
                                      "includedir_internal=#{include}/postgresql@16/internal"
    end
    chdir "contrib/hstore_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}/postgresql@16",
                                      "pkglibdir=#{lib}/postgresql@16",
                                      "includedir=#{include}/postgresql@16",
                                      "pkgincludedir=#{include}/postgresql@16",
                                      "includedir_server=#{include}/postgresql@16/server",
                                      "includedir_internal=#{include}/postgresql@16/internal"
    end
    chdir "contrib/ltree_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}/postgresql@16",
                                      "pkglibdir=#{lib}/postgresql@16",
                                      "includedir=#{include}/postgresql@16",
                                      "pkgincludedir=#{include}/postgresql@16",
                                      "includedir_server=#{include}/postgresql@16/server",
                                      "includedir_internal=#{include}/postgresql@16/internal"
    end
    chdir "contrib/jsonb_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}/postgresql@16",
                                      "pkglibdir=#{lib}/postgresql@16",
                                      "includedir=#{include}/postgresql@16",
                                      "pkgincludedir=#{include}/postgresql@16",
                                      "includedir_server=#{include}/postgresql@16/server",
                                      "includedir_internal=#{include}/postgresql@16/internal"
    end
    (lib/"postgresql@16").install Dir["stage/**/lib/postgresql@16/*"]
    # (include/"postgresql@16/server").install Dir["stage/**/include/postgresql@16/server/*"]
    # (share/"postgresql@16").install Dir["stage/**/share/postgresql@16/*"]
    # (share/"postgresql@16/extension").install Dir["stage/**/share/postgresql@16/extension/*"]
  end
end
