class PostgresqlPlpyAT16 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v16.7/postgresql-16.7.tar.bz2"
  sha256 "62e02f77ebfc4a37f1700c20cc3ccd85ff797b5613766ebf949a7899bb2113fe"
  license "PostgreSQL"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(16(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://www.conversence.com/bottles"
    sha256 cellar: :any, arm64_sequoia: "bb6346bd496c069310f4fcb20509171c6019a8a58fe68143995e3f8c64f434f6"
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2028-11-09", because: :unsupported

  depends_on "postgresql@16"
  depends_on "python@3.12"

  def install
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"
    ENV.prepend "PYTHON", "#{HOMEBREW_PREFIX}/opt/python@3.12/bin/python3.12"

    # Fix 'libintl.h' file not found for extensions
    # Update config to fix `error: could not find function 'gss_store_cred_into' required for GSSAPI`
    if OS.mac?
      ENV.prepend "LDFLAGS", "-L#{Formula["gettext"].opt_lib} -L#{Formula["krb5"].opt_lib}"
      ENV.prepend "CPPFLAGS", "-I#{Formula["gettext"].opt_include} -I#{Formula["krb5"].opt_include}"
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
