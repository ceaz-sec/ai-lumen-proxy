FROM python:3.11-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    rustc \
    cargo \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/mitmz-venv
ENV PATH="/opt/mitmz-venv/bin:${PATH}"
RUN pip install --no-cache-dir mitmproxy


FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash mitmz

COPY --from=builder /opt/mitmz-venv /opt/mitmz-venv
ENV PATH="/opt/mitmz-venv/bin:${PATH}"

RUN mkdir -p /home/mitmz/.mitmproxy && chown -R mitmz:mitmz /home/mitmz/.mitmproxy

USER mitmz
WORKDIR /home/mitmz
RUN mitmdump --listen-port 18080 & sleep 5 && kill %1 || true

USER root
RUN cp /home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem \
        /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt && \
    update-ca-certificates

ENV SSL_CERT_FILE="/home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem"
ENV CA_CERTIFICATE="/home/mitmz/.mitmproxy/mitmproxy-ca-cert.pem"

VOLUME ["/home/mitmz/.mitmproxy"]

EXPOSE 8080
EXPOSE 8081

HEALTHCHECK --interval=10s --timeout=3s \
    CMD wget -qO- http://127.0.0.1:8081/ || exit 1

USER mitmz
