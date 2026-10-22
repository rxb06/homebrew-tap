class Credactor < Formula
  include Language::Python::Virtualenv

  desc "Scan and redact hardcoded credentials in source trees"
  homepage "https://github.com/rxb06/credactor"
  url "https://files.pythonhosted.org/packages/e9/49/eb4eaecdaab99d5c1653ff7d96e9ac20d43e628493a0f41dca8e8952c2b0/credactor-2.7.5.tar.gz"
  sha256 "16b13bdc442aac62b7eb1648817d1f95a750d7ef35b91397e0c8db37cc534ba7"
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
    url "https://files.pythonhosted.org/packages/33/1c/f41d4e74c28ab327ff3acd36053f7ea506c55872d7a90b0fa71aa3ab0c89/charset_normalizer-3.5.2.tar.gz"
    sha256 "39de2a259fc954455c57274dc94c79d5842774e1247a016aff30bc0efed0f4ef"
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
