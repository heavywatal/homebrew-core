class Meson < Formula
  desc "Fast and user friendly build system"
  homepage "https://mesonbuild.com/"
  url "https://github.com/mesonbuild/meson/releases/download/0.54.1/meson-0.54.1.tar.gz"
  sha256 "2f76fb4572762be13ee479292610091b4509af5788bcceb391fe222bcd0296dc"
  revision 2
  head "https://github.com/mesonbuild/meson.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "82d63cb000617bab25c658c0279db5d2355b01338f156c9c2e43f37d274ed168" => :catalina
    sha256 "82d63cb000617bab25c658c0279db5d2355b01338f156c9c2e43f37d274ed168" => :mojave
    sha256 "82d63cb000617bab25c658c0279db5d2355b01338f156c9c2e43f37d274ed168" => :high_sierra
  end

  depends_on "ninja"
  depends_on "python@3.8"

  def install
    Language::Python.rewrite_python_shebang(Formula["python@3.8"].opt_bin/"python3")

    version = Language::Python.major_minor_version Formula["python@3.8"].bin/"python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"

    system Formula["python@3.8"].bin/"python3", *Language::Python.setup_install_args(prefix)

    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    (testpath/"helloworld.c").write <<~EOS
      main() {
        puts("hi");
        return 0;
      }
    EOS
    (testpath/"meson.build").write <<~EOS
      project('hello', 'c')
      executable('hello', 'helloworld.c')
    EOS

    mkdir testpath/"build" do
      system "#{bin}/meson", ".."
      assert_predicate testpath/"build/build.ninja", :exist?
    end
  end
end
