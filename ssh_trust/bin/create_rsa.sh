#!/bin/bash

expect <<-EOF
spawn ssh-keygen -t rsa
      expect {
          "*.ssh/id_rsa" { send "\r"; exp_continue }
          "*empty for no passphrase" { send "\r"; exp_continue }
          "again:" { send "\r" }
        }
interact
expect eof 
EOF
