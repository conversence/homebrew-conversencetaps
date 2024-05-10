class PostgresqlPlpyAT16 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v16.3/postgresql-16.3.tar.bz2"
  sha256 "331963d5d3dc4caf4216a049fa40b66d6bcb8c730615859411b9518764e60585"
  license "PostgreSQL"

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

    # Fix 'libintl.h' file not found for extensions
    ENV.prepend "LDFLAGS", "-L#{Formula["gettext"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["gettext"].opt_include}"

    args = std_configure_args + %W[
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql@16
      --libdir=#{lib}
      --includedir=#{include}
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
    system "make", "pkglibdir=#{lib}/postgresql",
                   "pkgincludedir=#{include}/postgresql",
                   "includedir_server=#{include}/postgresql/server"
    mkdir "stage"
    chdir "src/pl/plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    chdir "contrib/hstore_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    chdir "contrib/ltree_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    chdir "contrib/jsonb_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@16",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    (lib/"postgresql").install Dir["stage/**/lib/postgresql/*"]
    (include/"postgresql/server").install Dir["stage/**/include/postgresql/server/*"]
    (share/"postgresql@16").install Dir["stage/**/share/postgresql@16/*"]
    (share/"postgresql@16/extension").install Dir["stage/**/share/postgresql@16/extension/*"]
  end
end
