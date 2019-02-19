# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
# https://docs.ruby-lang.org/en/2.4.0/OpenSSL/X509/Certificate.html
# https://arusso.io/Generating_a_SAN_Certificate_in_Ruby/
# https://gist.github.com/tadast/9932075#gistcomment-2642851
# https://medium.com/@alex9pro/добавление-ssl-сертификата-в-rails-приложение-5959b0da4da9
if Rails.env.development?

  localhost_key = "#{Dir.pwd}/#{File.join('config', 'certs', 'localhost.key')}"
  localhost_cert = "#{Dir.pwd}/#{File.join('config', 'certs', 'localhost.crt')}"

  unless File.exist?(localhost_key)
    def generate_root_cert(root_key)
      sans      = ['localhost']
      sans.map! do |san|
        san = "DNS:#{san}"
      end

      exts = [
          [ "basicConstraints", "CA:FALSE", false ],
          [ "keyUsage", "Digital Signature, Non Repudiation, Key Encipherment", false],
      ]
      exts << [ "subjectAltName", sans.join(','), false ]
      ef = OpenSSL::X509::ExtensionFactory.new
      exts = exts.map do |ext|
        ef.create_extension(*ext)
      end

      root_ca = OpenSSL::X509::Certificate.new
      root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
      root_ca.serial = 0x0
      root_ca.subject = OpenSSL::X509::Name.parse "/C=BE/O=A1/OU=A/CN=localhost"
      root_ca.issuer = root_ca.subject # root CA's are "self-signed"
      root_ca.public_key = root_key.public_key
      root_ca.not_before = Time.now
      root_ca.not_after = root_ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = root_ca
      ef.issuer_certificate = root_ca
      exts.each do |ext|
        root_ca.add_extension(ext)
      end
      root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)

      root_ca
    end

    root_key = OpenSSL::PKey::RSA.new(2048)
    file = File.new( localhost_key, "wb")
    file.write(root_key)
    file.close

    root_cert = generate_root_cert(root_key)
    file = File.new( localhost_cert, "wb")
    file.write(root_cert)
    file.close
  end

  ssl_bind '127.0.0.1', '3001', {
      key: localhost_key,
      cert: localhost_cert
  }
end