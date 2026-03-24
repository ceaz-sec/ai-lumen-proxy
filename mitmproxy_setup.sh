!/bin/bash

pip install mitmproxy
mitmproxy --version

mkdir -p /usr/local/share/ca-certificates/

wget -e https_proxy=127.0.0.1:8080 --ca-certificate ~/.mitmproxy/mitmproxy-ca-cert.pem https://example.com/

sleep 5

cp ~/.mitmproxy/mitmproxy-ca-cert.pem /etc/pki/ca-trust/source/anchors/
trust list | grep -i mitmproxy #validate mitmproxy

cp ~/.mitmproxy/mitmproxy-ca-cert.pem /etc/pki/ca-trust/source/anchors/
mitmproxy --set request_client_cert=True --set client_certs=client-cert.pem~
