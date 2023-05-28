
class PostgresqlPlpyAT14 < Formula
  desc "Python3 as procedural language for Postgres"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v14.7/postgresql-14.7.tar.bz2"
  sha256 "cef60f0098fa8101c1546f4254e45b722af5431337945b37af207007630db331"
  license "PostgreSQL"
  @@pgname = "postgresql@14"
  @@pyname = "python@3.10"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(14+(?:\.\d+)+)/?["' >]}i)
  end

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2026-11-12", because: :unsupported

  depends_on "#@@pyname"
  depends_on "#@@pgname"

  def install
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@1.1"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@1.1"].opt_include} -I#{Formula["readline"].opt_include}"
    ENV.prepend "PYTHON", "#{HOMEBREW_PREFIX}/opt/#{@@pyname}/bin/python3.10"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{HOMEBREW_PREFIX}/share/#{@@pgname}
      --libdir=#{HOMEBREW_PREFIX}/lib/#{@@pgname}
      --includedir=#{HOMEBREW_PREFIX}/include/#{@@pgname}
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
                                      "datadir=#{HOMEBREW_PREFIX}/share/#{@@pgname}",
                                      "libdir=#{lib}/#{@@pgname}",
                                      "pkglibdir=#{lib}/#{@@pgname}",
                                      "includedir=#{include}/#{@@pgname}",
                                      "pkgincludedir=#{include}/#{@@pgname}",
                                      "includedir_server=#{include}/#{@@pgname}/server",
                                      "includedir_internal=#{include}/#{@@pgname}/internal"
    end
    chdir "contrib/hstore_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/#{@@pgname}",
                                      "libdir=#{lib}/#{@@pgname}",
                                      "pkglibdir=#{lib}/#{@@pgname}",
                                      "includedir=#{include}/#{@@pgname}",
                                      "pkgincludedir=#{include}/#{@@pgname}",
                                      "includedir_server=#{include}/#{@@pgname}/server",
                                      "includedir_internal=#{include}/#{@@pgname}/internal"
end
    chdir "contrib/ltree_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/#{@@pgname}",
                                      "libdir=#{lib}/#{@@pgname}",
                                      "pkglibdir=#{lib}/#{@@pgname}",
                                      "includedir=#{include}/#{@@pgname}",
                                      "pkgincludedir=#{include}/#{@@pgname}",
                                      "includedir_server=#{include}/#{@@pgname}/server",
                                      "includedir_internal=#{include}/#{@@pgname}/internal"
  end
    chdir "contrib/jsonb_plpython" do
      system "make", "install", "DESTDIR=#{buildpath}/stage",
                                      "datadir=#{HOMEBREW_PREFIX}/share/#{@@pgname}",
                                      "libdir=#{lib}/#{@@pgname}",
                                      "pkglibdir=#{lib}/#{@@pgname}",
                                      "includedir=#{include}/#{@@pgname}",
                                      "pkgincludedir=#{include}/#{@@pgname}",
                                      "includedir_server=#{include}/#{@@pgname}/server",
                                      "includedir_internal=#{include}/#{@@pgname}/internal"
  end
    (lib/"#{@@pgname}").install Dir["stage/**/lib/#{@@pgname}/*"]
    (lib/"#{@@pgname}/pgxs/src/pl/plpython").install Dir["stage/**/lib/#{@@pgname}/pgxs/src/pl/plpython/*"]
    (include/"#{@@pgname}/server").install Dir["stage/**/include/#{@@pgname}/server/*"]
    (share/"#{@@pgname}/extension").install Dir["stage/**/share/#{@@pgname}/extension/*"]
  end
end
