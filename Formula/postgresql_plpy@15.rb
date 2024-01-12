class PostgresqlPlpyAT15 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v15.5/postgresql-15.5.tar.bz2"
  sha256 "8f53aa95d78eb8e82536ea46b68187793b42bba3b4f65aa342f540b23c9b10a6"
  license "PostgreSQL"
  revision 2

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(15(?:\.\d+)+)/?["' >]}i)
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2027-11-11", because: :unsupported

  depends_on "postgresql@15"
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
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql@15
      --libdir=#{HOMEBREW_PREFIX}/lib/postgresql@15
      --includedir=#{HOMEBREW_PREFIX}/include/postgresql@15
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
    system "make", "pkglibdir=#{lib}/postgresql@15",
                   "pkgincludedir=#{include}/postgresql@15",
                   "includedir_server=#{include}/postgresql@15/server"
    mkdir "stage"
    chdir "src/pl/plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@15",
                                      "libdir=#{lib}/postgresql@15",
                                      "pkglibdir=#{lib}/postgresql@15",
                                      "includedir=#{include}/postgresql@15",
                                      "pkgincludedir=#{include}/postgresql@15",
                                      "includedir_server=#{include}/postgresql@15/server",
                                      "includedir_internal=#{include}/postgresql@15/internal"
    end
    chdir "contrib/hstore_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@15",
                                      "libdir=#{lib}/postgresql@15",
                                      "pkglibdir=#{lib}/postgresql@15",
                                      "includedir=#{include}/postgresql@15",
                                      "pkgincludedir=#{include}/postgresql@15",
                                      "includedir_server=#{include}/postgresql@15/server",
                                      "includedir_internal=#{include}/postgresql@15/internal"
    end
    chdir "contrib/ltree_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@15",
                                      "libdir=#{lib}/postgresql@15",
                                      "pkglibdir=#{lib}/postgresql@15",
                                      "includedir=#{include}/postgresql@15",
                                      "pkgincludedir=#{include}/postgresql@15",
                                      "includedir_server=#{include}/postgresql@15/server",
                                      "includedir_internal=#{include}/postgresql@15/internal"
    end
    chdir "contrib/jsonb_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{share}/postgresql@15",
                                      "libdir=#{lib}/postgresql@15",
                                      "pkglibdir=#{lib}/postgresql@15",
                                      "includedir=#{include}/postgresql@15",
                                      "pkgincludedir=#{include}/postgresql@15",
                                      "includedir_server=#{include}/postgresql@15/server",
                                      "includedir_internal=#{include}/postgresql@15/internal"
    end
    (lib/"postgresql@15").install Dir["stage/**/lib/postgresql@15/*"]
    (include/"postgresql@15/server").install Dir["stage/**/include/postgresql@15/server/*"]
    (share/"postgresql@15").install Dir["stage/**/share/postgresql@15/*"]
    (share/"postgresql@15/extension").install Dir["stage/**/share/postgresql@15/extension/*"]
  end
end
