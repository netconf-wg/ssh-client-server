
echo "Testing YANG module syntax..."
pyang --ietf --max-line-length=70 -p ../ ../ietf-ssh-client\@*.yang
pyang --ietf --max-line-length=70 -p ../ ../ietf-ssh-server\@*.yang
pyang --ietf --max-line-length=70 -p ../ ../ietf-ssh-common\@*.yang
yanglint -p ../ ../ietf-ssh-client\@*.yang
yanglint -p ../ ../ietf-ssh-server\@*.yang
yanglint -p ../ ../ietf-ssh-common\@*.yang


echo "Testing ex-ssh-common.xml..."
yanglint -p ../ -s ../ietf-ssh-common\@*.yang ex-ssh-common.xml

echo "Testing ex-ssh-client.xml..."
yanglint -m -p ../ -s ../ietf-ssh-client\@*.yang ../ietf-ssh-common\@*.yang ex-ssh-client.xml ../../keystore/refs/ex-keystore.xml

echo "Testing ex-ssh-server.xml..."
yanglint -m -p ../ -s ../ietf-ssh-server\@*.yang ../ietf-ssh-common\@*.yang ex-ssh-server.xml ../../keystore/refs/ex-keystore.xml

