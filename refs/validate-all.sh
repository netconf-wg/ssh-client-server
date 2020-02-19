#!/bin/bash

echo "Testing ietf-ssh-client (pyang)..."
pyang --ietf --max-line-length=69 -p ../ ../ietf-ssh-client\@*.yang

echo "Testing ietf-ssh-client (yanglint)..."
yanglint -p ../ ../ietf-ssh-client\@*.yang

echo "Testing ietf-ssh-server (pyang)..."
pyang --ietf --max-line-length=69 -p ../ ../ietf-ssh-server\@*.yang

echo "Testing ietf-ssh-server (yanglint)..."
yanglint -p ../ ../ietf-ssh-server\@*.yang

echo "Testing ietf-ssh-common (pyang)..."
pyang --ietf --max-line-length=69 -p ../ ../ietf-ssh-common\@*.yang

echo "Testing ietf-ssh-common (yanglint)..."
yanglint -p ../ ../ietf-ssh-common\@*.yang


echo "Testing ex-ssh-common.xml..."
name=`ls -1 ../ietf-ssh-common\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container transport-params { uses transport-params-grouping; }}/' ../ietf-ssh-common\@*.yang > $name
yanglint -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang $name ex-ssh-common.xml
rm $name

echo "Testing ex-ssh-client-local.xml..."
name=`ls -1 ../ietf-ssh-client\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-client { uses ssh-client-grouping; }}/' ../ietf-ssh-client\@*.yang > $name
yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-client-local.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml
rm $name

echo "Testing ex-ssh-client-keystore.xml..."
name=`ls -1 ../ietf-ssh-client\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-client { uses ssh-client-grouping; }}/' ../ietf-ssh-client\@*.yang > $name
command="yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-client-keystore.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml"
#echo $command
`$command`
rm $name

echo "Testing ex-ssh-server-local.xml..."
name=`ls -1 ../ietf-ssh-server\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-server { uses ssh-server-grouping; }}/' ../ietf-ssh-server\@*.yang > $name
yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ex-ssh-server-local.xml ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml
rm $name

echo "Testing ex-ssh-server-keystore.xml..."
name=`ls -1 ../ietf-ssh-server\@*.yang | sed 's/\.\.\///'`
sed 's/^}/container ssh-server { uses ssh-server-grouping; }}/' ../ietf-ssh-server\@*.yang > $name
command="yanglint -m -s ../ietf-crypto-types\@*.yang ../ietf-truststore\@*.yang ../ietf-keystore\@*.yang ../ietf-ssh-common\@*.yang ./ietf-origin.yang $name ../../trust-anchors/refs/ex-truststore.xml ../../keystore/refs/ex-keystore.xml ex-ssh-server-keystore.xml"
#echo $command
`$command`
rm $name

