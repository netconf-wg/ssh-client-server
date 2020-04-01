#!/bin/bash

run_unix_cmd() {
  # $1 is the line number
  # $2 is the cmd to run
  # $3 is the expected exit code
  output=`$2 2>&1`
  exit_code=$?
  if [[ $exit_code -ne $3 ]]; then
    printf "failed (incorrect exit status code) on line $1.\n"
    printf "  - exit code: $exit_code (expected $3)\n"
    printf "  - command: $2\n"
    if [[ -z $output ]]; then
      printf "  - output: <none>\n\n"
    else
      printf "  - output: <starts on next line>\n$output\n\n"
    fi
    exit 1
  fi
}

printf "Testing ietf-ssh-client (pyang)..."
command="pyang -Werror --ietf --max-line-length=69 -p ../ ../ietf-ssh-client\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ietf-ssh-client (yanglint)..."
command="yanglint -p ../ ../ietf-ssh-client\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ietf-ssh-server (pyang)..."
command="pyang -Werror --ietf --max-line-length=69 -p ../ ../ietf-ssh-server\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ietf-ssh-server (yanglint)..."
command="yanglint -p ../ ../ietf-ssh-server\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ietf-ssh-common (pyang)..."
command="pyang -Werror --ietf --max-line-length=69 -p ../ ../ietf-ssh-common\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ietf-ssh-common (yanglint)..."
command="yanglint -p ../ ../ietf-ssh-common\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"


printf "Testing ex-ssh-common.xml..."
name=`ls -1 ../ietf-ssh-common\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container transport-params { uses transport-params-grouping; }}/' ../ietf-ssh-common\@*.yang > $name
command="yanglint -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang $name ex-ssh-common.xml"
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-ssh-client-local.xml..."
name=`ls -1 ../ietf-ssh-client\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-client { uses ssh-client-grouping; }}/' ../ietf-ssh-client\@*.yang > $name
command="yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-client-local.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml"
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-ssh-client-keystore.xml..."
name=`ls -1 ../ietf-ssh-client\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-client { uses ssh-client-grouping; }}/' ../ietf-ssh-client\@*.yang > $name
command="yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-client-keystore.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml"
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-ssh-server-local.xml..."
name=`ls -1 ../ietf-ssh-server\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-server { uses ssh-server-grouping; }}/' ../ietf-ssh-server\@*.yang > $name
command="yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-server-local.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml"
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-ssh-server-keystore.xml..."
name=`ls -1 ../ietf-ssh-server\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-server { uses ssh-server-grouping; }}/' ../ietf-ssh-server\@*.yang > $name
command="yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml ex-ssh-server-keystore.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"
rm $name

