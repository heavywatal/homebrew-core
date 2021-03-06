class Urh < Formula
  desc "Universal Radio Hacker"
  homepage "https://github.com/jopohl/urh"
  url "https://files.pythonhosted.org/packages/7a/4b/d343f4cd7409d61cf69fdf9c450fc1b048c24258e248747670f653dba9c7/urh-2.8.7.tar.gz"
  sha256 "def9be4f4464875549e4d49bf3c7fa4bdc496c1b34e275aa62128b401f8efca6"
  head "https://github.com/jopohl/urh.git"

  bottle do
    sha256 "fc7d66c568820faa8600f7a4d495c115e794b8fc204277365d92d927d9b0df91" => :catalina
    sha256 "62c872b7bd5c3878af8e792223c6891ee8a4f9e3a5d60e922e72d3c1d95507de" => :mojave
    sha256 "0ea0af205225fd149ffe1fbaac853d6998ba0c6042ecd20ab3def68fac5bf03c" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "hackrf"
  depends_on "numpy"
  depends_on "pyqt"
  depends_on "python@3.8"
  depends_on "zeromq"

  resource "Cython" do
    url "https://files.pythonhosted.org/packages/99/36/a3dc962cc6d08749aa4b9d85af08b6e354d09c5468a3e0edc610f44c856b/Cython-0.29.17.tar.gz"
    sha256 "6361588cb1d82875bcfbad83d7dd66c442099759f895cf547995f00601f9caf2"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/c4/b8/3512f0e93e0db23a71d82485ba256071ebef99b227351f0f5540f744af41/psutil-5.7.0.tar.gz"
    sha256 "685ec16ca14d079455892f25bd124df26ff9137664af445563c1bd36629b5e0e"
  end

  resource "pyzmq" do
    url "https://files.pythonhosted.org/packages/16/4c/762c2c3063c4d45baf4a49acea7a4f561f7b78a45cd04b58d63f4c5f6b8d/pyzmq-19.0.0.tar.gz"
    sha256 "5e1f65e576ab07aed83f444e201d86deb01cd27dcf3f37c727bc8729246a60a8"
  end

  def install
    xy = Language::Python.major_minor_version Formula["python@3.8"].opt_bin/"python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"
    resources.each do |r|
      next if r.name == "Cython"

      r.stage do
        system Formula["python@3.8"].opt_bin/"python3", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    saved_python_path = ENV["PYTHONPATH"]
    ENV.prepend_create_path "PYTHONPATH", buildpath/"cython/lib/python#{xy}/site-packages"

    resource("Cython").stage do
      system Formula["python@3.8"].opt_bin/"python3", *Language::Python.setup_install_args(buildpath/"cython")
    end

    system Formula["python@3.8"].opt_bin/"python3", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => saved_python_path)
  end

  test do
    xy = Language::Python.major_minor_version Formula["python@3.8"].opt_bin/"python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    (testpath/"test.py").write <<~EOS
      from urh.util.GenericCRC import GenericCRC;
      c = GenericCRC();
      expected = [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0]
      assert(expected == c.crc([0, 1, 0, 1, 1, 0, 1, 0]).tolist())
    EOS
    system Formula["python@3.8"].opt_bin/"python3", "test.py"
  end
end
