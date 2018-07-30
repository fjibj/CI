#!/bin/bash

function ssh_normal()
{
expect <<-EOF
spawn ssh  $1@$2  $3
expect {
          "*yes/no" { send "yes\r"; exp_continue }
          "*password:" { exp_send "$4\r"; exp_continue }
        }
interact
expect eof
EOF
}

function scp_normal()
{
expect <<-EOF
spawn scp -r $1 $2@$3:$4
expect {
          "*yes/no" { send "yes\r"; exp_continue }
          "*password:" { send "$5\r"; exp_continue }
        }
interact
expect eof
EOF
}


function ssh_copy_id()
{
expect <<-EOF
spawn ssh-copy-id $1@$2
expect {
          "*yes/no" { send "yes\r"; exp_continue }
          "*password:" { exp_send "$3\r"}
        }
interact
expect eof
EOF
}

