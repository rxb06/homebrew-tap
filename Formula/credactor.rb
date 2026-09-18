class Credactor < Formula
  include Language::Python::Virtualenv

  desc "Scan and redact hardcoded credentials in source trees"
  homepage "https://github.com/rxb06/credactor"
  url "https://files.pythonhosted.org/packages/10/8b/6b16080aeaccbd0f81925648f97e4622587727d0b3d3c7545a9cf442a220/credactor-2.7.4.tar.gz"
  sha256 "0eb7e1f6457a15c648a697304829f0398214bad52c36a1ee1f7a162fbf97e32e"
  license "Apache-2.0"

  # Explicit rather than guessed, so the daily autobump workflow keeps
  # resolving new releases if the PyPI URL layout ever changes.
  livecheck do
    url :stable
    strategy :pypi
  end

  # 3.13 is the newest interpreter in Credactor's CI matrix. Move this forward
  # only once the matrix covers the newer version.
  depends_on "python@3.13"

  # Credactor has no required runtime dependencies. This is its optional
  # [encoding] extra: without it, non-UTF-8 files are read as Latin-1 and their
  # secrets can be missed (Credactor warns, but the finding is still lost).
  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/e5/3f/143b048436775b0f76ac3eec145c019e8173ccc2885c8f20319b996d5e83/charset_normalizer-3.5.1.tar.gz"
    sha256 "6117b84ea48435e5356dc737f5121485c30920ba43375fa7b434fd753df0eac3"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/credactor --version")

    # A clean tree exits 0.
    (testpath/"clean").mkpath
    (testpath/"clean/ok.py").write "x = 1\n"
    system bin/"credactor", "--ci", testpath/"clean"

    # A planted credential exits 1 and is reported. The value must be masked to
    # its first four characters: the full secret never reaches any output
    # format, which is the property worth regression-testing on every bump.
    (testpath/"dirty").mkpath
    (testpath/"dirty/config.py").write %Q(aws_key = "AKIAIOSFODNN7EXAMPLE"\n)
    output = shell_output("#{bin}/credactor --ci --format json #{testpath}/dirty", 1)
    assert_match "\"count\": 1", output
    assert_match "pattern:AWS access key", output
    assert_match "AKIA[REDACTED]", output
    refute_match "AKIAIOSFODNN7EXAMPLE", output
  end
end
