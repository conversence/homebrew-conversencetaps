class PostgresqlPlpyAT16 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v16.15/postgresql-16.15.tar.bz2"
  sha256 "c1575341fa7bd40f5274ea465b34390f4dc64cdd0770af327005caaeb9f6b7ed"
  license "PostgreSQL"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(16(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://www.conversence.com/bottles"
    sha256 cellar: :any, arm64_tahoe: "088a425db6604dd9fce7d4312222728bb7fc83bd3e23f1c05ba527b4c56657b4"
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2028-11-09", because: :unsupported

  depends_on "pkgconf" => :build
  depends_on "postgresql@16"
  depends_on "python@3.12"

  def install
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{formula_opt_lib("openssl@3")} -L#{formula_opt_lib("readline")}"
    ENV.prepend "CPPFLAGS", "-I#{formula_opt_include("openssl@3")} -I#{formula_opt_include("readline")}"
    ENV.prepend "PYTHON", "#{HOMEBREW_PREFIX}/opt/python@3.12/bin/python3.12"

    # Fix 'libintl.h' file not found for extensions
    # Update config to fix `error: could not find function 'gss_store_cred_into' required for GSSAPI`
    if OS.mac?
      ENV.prepend "LDFLAGS", "-L#{formula_opt_lib("gettext")} -L#{formula_opt_lib("krb5")}"
      ENV.prepend "CPPFLAGS", "-I#{formula_opt_include("gettext")} -I#{formula_opt_include("krb5")}"
    end

    args = std_configure_args + %W[
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql@16
      --libdir=#{lib}
      --includedir=#{include}
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --localedir=#{HOMEBREW_PREFIX}/share/locale
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
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if OS.mac?

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
