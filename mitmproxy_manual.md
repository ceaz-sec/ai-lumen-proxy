# MITMPROXY MANUAL DOCKER BUILD

- docker run -it --rm -p 8080:8080 -p 8081:8081 python:3.11-alpine /bin/sh

# Root
- apk add --no-cache \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    rust cargo \
    && apk add --no-cache \
    gcc g++ musl-dev libffi-dev openssl-dev make ca-certificates curl wget
    
- adduser -D -h /home/mitmz mitmz

- mkdir -p /home/mitmz/.mitmproxy && chown -R mitmz:mitmz /home/mitmz/.mitmproxy

- su -mitmz

# Mitmz User
- python -m venv ./venv

- source .venv/bin/activate

- pip install mitmproxy
# Create mitmproxy cert
- mitmdump -p 18080 | sleep 5  && kill %1  || true

#Root
- cp /home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem \ /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt && update-ca-certificates

- CA_CERTIFICATE="/home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem" \
SSL_CERT_FILE="/home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem"

# Local Machine
- sudo docker ps #get mitmz container id

- docker cp <docker-container-id>:/home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem ~/mitmproxy-ca-cert.pem 

- docker commit <container-id> mitmz-one

- exit container # From a different terminial tab

# Add contiainers cert to yours to avoid untrust errors
- certutil -d sql:$HOME/.pki/nssdb -A   -n "mitmproxy"   -t "CT,,"   -i ~/mitmproxy-ca-cert.pem

# Start Mitmproxy container image
- sudo docker run -it --rm -p 8080:8080 -p 8081:8081 mitmz-one /bin/sh

# Start Google chrome from Local machine
- google-chrome   --proxy-server="127.0.0.1:8080"   --disable-quic   --user-data-dir=/tmp/lab-profile
