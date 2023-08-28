class PostgresqlPlpyAT15 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v15.4/postgresql-15.4.tar.bz2"
  sha256 "baec5a4bdc4437336653b6cb5d9ed89be5bd5c0c58b94e0becee0a999e63c8f9"
  license "PostgreSQL"
  revision 1

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(15(?:\.\d+)+)/?["' >]}i)
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2027-11-11", because: :unsupported

  depends_on "postgresql@15"
  depends_on "python@3.10"

  def install
    print "#{buildpath}/stage"
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"
    ENV.prepend "PYTHON", "#{HOMEBREW_PREFIX}/opt/python@3.10/bin/python3.10"

    # Fix 'libintl.h' file not found for extensions
    ENV.prepend "LDFLAGS", "-L#{Formula["gettext"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["gettext"].opt_include}"

    args = std_configure_args + %W[
      --prefix=#{prefix}
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql@15
      --libdir=#{opt_lib}
      --includedir=#{opt_include}
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
      --with-openssl
      --with-pam
      --with-python
      --with-uuid=e2fs
    ]
    if OS.mac?
      args += %w[
        --with-bonjour
        --with-tcl
      ]
    end

    # PostgreSQL by default uses xcodebuild internally to determine this,
    # which does not work on CLT-only installs.
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if MacOS.sdk_root_needed?

    system "./configure", *args
    system "make", "pkglibdir=#{opt_lib}/postgresql",
                   "pkgincludedir=#{opt_include}/postgresql",
                   "includedir_server=#{opt_include}/postgresql/server"
    mkdir "stage"
    chdir "src/pl/plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@15",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    chdir "contrib/hstore_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@15",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    chdir "contrib/ltree_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@15",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    chdir "contrib/jsonb_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@15",
                                      "libdir=#{lib}",
                                      "pkglibdir=#{lib}/postgresql",
                                      "includedir=#{include}",
                                      "pkgincludedir=#{include}/postgresql",
                                      "includedir_server=#{include}/postgresql/server",
                                      "includedir_internal=#{include}/postgresql/internal"
    end
    (lib/"postgresql").install Dir["stage/**/lib/postgresql/*"]
    (include/"postgresql/server").install Dir["stage/**/include/postgresql/server/*"]
    (share/"postgresql@15/extension").install Dir["stage/**/share/postgresql@15/extension/*"]
  end
end
