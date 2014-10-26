dovecot:
  lookup:
    pkgs:
      - dovecot-imapd
      - dovecot-sieve
      - dovecot-managesieved
      - dovecot-ldap
  settings:
    common:
      - name: Misc settings
        login_greeting: server ready
        listen: '*, [::]'
        protocols: imap pop3 lmtp
        mail_plugins: quota sieve
    lda:
      - name: LDA specific settings (also used by LMTP)
        postmaster_address: postmaster@domain.local
        hostname: dovecot.domain.local
    lmtp:
      - name: LMTP
        sect_append: |
            protocol lmtp {
              mail_plugins = $mail_plugins sieve
            }
    logging:
      - name: Logging
        auth_verbose: 'yes'
        verbose_ssl: 'yes'
        log_timestamp: '"%Y-%m-%d %H:%M:%S "'
        login_log_format_elements: '"user=<%u> method=%m rip=%r lip=%l mpid=%e %c %k"'
    auth:
      - name: Authentication processes
        disable_plaintext_auth: 'yes'
        auth_mechanisms: login cram-md5
    master:
      - name: Master
        sect_append: |
            service imap-login {
              inet_listener imaps {
                port = 0
              }
              service_count = 0
              process_min_avail = 8
            }

            service pop3-login {
              inet_listener pop3s {
                port = 0
              }
              service_count = 0
            }
...
