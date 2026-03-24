# ai-lumen-proxy

A mitmproxy-based tool for intercepting and blocking outbound traffic to unauthorized AI services.

---

## What It Does

- Blocks or redirects requests to a configurable list of AI domains
- Logs suspicious traffic to `browser_alerts.log` and `alerts.jsonl`
- Detects PII keywords in outbound request bodies
- Flags large responses and auth-related endpoints

---

## Setup

Requires Docker and a Chromium-based browser.

**1. Run a base container and install dependencies**

```bash
docker run -it --rm -p 8080:8080 -p 8081:8081 python:3.11-alpine /bin/sh
```

Inside the container as root:

```bash
apk add --no-cache rust cargo gcc g++ musl-dev libffi-dev openssl-dev make ca-certificates curl wget
adduser -D -h /home/mitmz mitmz
mkdir -p /home/mitmz/.mitmproxy && chown -R mitmz:mitmz /home/mitmz/.mitmproxy
su - mitmz
```

**2. Install mitmproxy and generate the CA cert**

```bash
python -m venv ./venv
source .venv/bin/activate
pip install mitmproxy
mitmdump -p 18080 & sleep 5 && kill %1
```

**3. Trust the cert on the host**

```bash
# As root inside container
cp /home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt
update-ca-certificates
```

```bash
# On your local machine
docker cp <container-id>:/home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem ~/mitmproxy-ca-cert.pem
certutil -d sql:$HOME/.pki/nssdb -A -n "mitmproxy" -t "CT,," -i ~/mitmproxy-ca-cert.pem
```

**4. Commit the container image**

```bash
docker commit <container-id> mitmz-one
```

---

## Usage

Start the container:

```bash
docker run -it --rm -p 8080:8080 -p 8081:8081 mitmz-one /bin/sh
```

Run the addon:

```bash
mitmproxy -s ai-lumen-block.py
```

Start Chrome routed through the proxy:

```bash
google-chrome --proxy-server="127.0.0.1:8080" --disable-quic --user-data-dir=/tmp/lab-profile
```

---

## Blocked Domains

Configured in `ai-lumen-block.py`. Defaults include:

- chatgpt.com
- claude.ai
- deepseek.ai
- perplexity.ai
- huggingface.co
- meta.ai
- character.ai
- otter.ai
- sesame.com

---

## Log Output

| File | Contents |
|------|----------|
| `browser_alerts.log` | Timestamped warnings for blocked domains, large responses, auth endpoints |
| `alerts.jsonl` | Structured JSON alerts per flagged event |

---

## Author

Marcus Morris (ceaz-sec) — github.com/ceaz-sec
