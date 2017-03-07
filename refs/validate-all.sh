
echo "Testing YANG syntax..."
pyang --ietf --max-line-length=70 -p ../ ../ietf-ssh-client\@*.yang
pyang --ietf --max-line-length=70 -p ../ ../ietf-ssh-server\@*.yang

exit

echo "Testing keystore module..."
./validate.sh ietf-keystore\@*.yang ex-keystore.xml
#./validate.sh ietf-keystore\@*.yang ex-keystore-rpc-gpk-restconf-json.xml
#./validate.sh ietf-keystore\@*.yang ex-keystore-rpc-gcsr-netconf.xml

echo "Testing ssh-server module..."
./validate.sh ietf-ssh-server\@*.yang ex-ssh-server.xml

echo "Testing tls-server module..."
./validate.sh ietf-tls-server\@*.yang ex-tls-server.xml

echo "Testing netconf-server module..."
./validate.sh ietf-netconf-server\@*.yang ex-netconf-server.xml

echo "Testing restconf-server module..."
./validate.sh ietf-restconf-server\@*.yang ex-restconf-server.xml


