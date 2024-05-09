class PostgresqlPlpyAT14 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v14.12/postgresql-14.12.tar.bz2"
  sha256 "6118d08f9ddcc1bd83cf2b7cc74d3b583bdcec2f37e6245a8ac003b8faa80923"
  license "PostgreSQL"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(14+(?:\.\d+)+)/?["' >]}i)
  end

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2026-11-12", because: :unsupported

  depends_on "postgresql@14"
  depends_on "python@3.11"

  def install
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"
    ENV.prepend "PYTHON", "#{HOMEBREW_PREFIX}/opt/python@3.11/bin/python3.11"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql@14
      --libdir=#{HOMEBREW_PREFIX}/lib/postgresql@14
      --includedir=#{HOMEBREW_PREFIX}/include/postgresql@14
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
    system "make"
    mkdir "stage"
    chdir "src/pl/plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@14",
                                      "libdir=#{lib}/postgresql@14",
                                      "pkglibdir=#{lib}/postgresql@14",
                                      "includedir=#{include}/postgresql@14",
                                      "pkgincludedir=#{include}/postgresql@14",
                                      "includedir_server=#{include}/postgresql@14/server",
                                      "includedir_internal=#{include}/postgresql@14/internal"
    end
    chdir "contrib/hstore_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@14",
                                      "libdir=#{lib}/postgresql@14",
                                      "pkglibdir=#{lib}/postgresql@14",
                                      "includedir=#{include}/postgresql@14",
                                      "pkgincludedir=#{include}/postgresql@14",
                                      "includedir_server=#{include}/postgresql@14/server",
                                      "includedir_internal=#{include}/postgresql@14/internal"
    end
    chdir "contrib/ltree_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@14",
                                      "libdir=#{lib}/postgresql@14",
                                      "pkglibdir=#{lib}/postgresql@14",
                                      "includedir=#{include}/postgresql@14",
                                      "pkgincludedir=#{include}/postgresql@14",
                                      "includedir_server=#{include}/postgresql@14/server",
                                      "includedir_internal=#{include}/postgresql@14/internal"
    end
    chdir "contrib/jsonb_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/postgresql@14",
                                      "libdir=#{lib}/postgresql@14",
                                      "pkglibdir=#{lib}/postgresql@14",
                                      "includedir=#{include}/postgresql@14",
                                      "pkgincludedir=#{include}/postgresql@14",
                                      "includedir_server=#{include}/postgresql@14/server",
                                      "includedir_internal=#{include}/postgresql@14/internal"
    end
    (lib/"postgresql@14").install Dir["stage/**/lib/postgresql@14/*"]
    (lib/"postgresql@14/pgxs/src/pl/plpython").install Dir["stage/**/lib/postgresql@14/pgxs/src/pl/plpython/*"]
    (include/"postgresql@14/server").install Dir["stage/**/include/postgresql@14/server/*"]
    (share/"postgresql@14/extension").install Dir["stage/**/share/postgresql@14/extension/*"]
  end
end
