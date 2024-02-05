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

# IANA modules

printf "Testing iana-ssh-encryption-algs (pyang)..."
#command="pyang -Werror --max-line-length=69 -p ../ ../iana-ssh-encryption-algs\@*.yang"
command="pyang -Werror -p ../ ../iana-ssh-encryption-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing iana-ssh-encryption-algs (yanglint)..."
command="yanglint -p ../ ../iana-ssh-encryption-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing iana-ssh-key-exchange-algs (pyang)..."
#command="pyang -Werror --max-line-length=69 -p ../ ../iana-ssh-key-exchange-algs\@*.yang"
command="pyang -Werror -p ../ ../iana-ssh-key-exchange-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing iana-ssh-key-exchange-algs (yanglint)..."
command="yanglint -p ../ ../iana-ssh-key-exchange-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing iana-ssh-mac-algs (pyang)..."
#command="pyang -Werror --max-line-length=69 -p ../ ../iana-ssh-mac-algs\@*.yang"
command="pyang -Werror -p ../ ../iana-ssh-mac-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing iana-ssh-mac-algs (yanglint)..."
command="yanglint -p ../ ../iana-ssh-mac-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing iana-ssh-public-key-algs (pyang)..."
#command="pyang -Werror --max-line-length=69 -p ../ ../iana-ssh-public-key-algs\@*.yang"
command="pyang -Werror -p ../ ../iana-ssh-public-key-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing iana-ssh-public-key-algs (yanglint)..."
command="yanglint -p ../ ../iana-ssh-public-key-algs\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"


# IETF modules

printf "Testing ietf-ssh-common (pyang)..."
command="pyang -Werror --ietf --max-line-length=69 -p ../ ../ietf-ssh-common\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ietf-ssh-common (yanglint)..."
command="yanglint -p ../ ../ietf-ssh-common\@*.yang"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

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


# IANA Examples



# IETF Examples

printf "Testing ex-ssh-common.xml..."
name=`ls -1 ../ietf-ssh-common\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container transport-params { uses transport-params-grouping; }}/' ../ietf-ssh-common\@*.yang > $name
command="yanglint ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../iana-ssh-encryption-algs\@*.yang ../iana-ssh-key-exchange-algs\@*.yang ../iana-ssh-mac-algs\@*.yang ../iana-ssh-public-key-algs\@*.yang $name ex-ssh-common.xml"
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-supported-algs.xml..."
command="yanglint ../iana-ssh-encryption-algs\@*.yang ../iana-ssh-key-exchange-algs\@*.yang ../iana-ssh-mac-algs\@*.yang ../iana-ssh-public-key-algs\@*.yang ../ietf-ssh-common\@*.yang ex-supported-algs.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ex-generate-asymmetric-key-pair-rpc.xml..."
command="yanglint  -t nc-rpc -O ../../keystore/refs/ex-keystore.xml ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../iana-ssh-encryption-algs\@*.yang ../iana-ssh-key-exchange-algs\@*.yang ../iana-ssh-mac-algs\@*.yang ../iana-ssh-public-key-algs\@*.yang ../ietf-ssh-common\@*.yang ex-generate-asymmetric-key-pair-rpc.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ex-generate-asymmetric-key-pair-rpc-reply.xml..."
command="yanglint -t nc-reply -O ../../keystore/refs/ex-keystore.xml -R ex-generate-asymmetric-key-pair-rpc.xml ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../iana-ssh-key-exchange-algs\@*.yang ../iana-ssh-mac-algs\@*.yang ../iana-ssh-public-key-algs\@*.yang ../ietf-ssh-common\@*.yang ex-generate-asymmetric-key-pair-rpc-reply.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing ex-ssh-client-inline.xml..."
name=`ls -1 ../ietf-ssh-client\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-client { uses ssh-client-grouping; }}/' ../ietf-ssh-client\@*.yang > $name
command="yanglint -m ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-client-inline.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml"
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-ssh-client-keystore.xml..."
name=`ls -1 ../ietf-ssh-client\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-client { uses ssh-client-grouping; }}/' ../ietf-ssh-client\@*.yang > $name
command="yanglint -m ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-client-keystore.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml"
#echo
#echo $command
#echo
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-ssh-server-inline.xml..."
name=`ls -1 ../ietf-ssh-server\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-server { uses ssh-server-grouping; }}/' ../ietf-ssh-server\@*.yang > $name
command="yanglint -m ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-server-inline.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml"
run_unix_cmd $LINENO "$command" 0
rm $name
printf "okay.\n"

printf "Testing ex-ssh-server-keystore.xml..."
name=`ls -1 ../ietf-ssh-server\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-server { uses ssh-server-grouping; }}/' ../ietf-ssh-server\@*.yang > $name
command="yanglint -m ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml ex-ssh-server-keystore.xml"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"
rm $name
