import logging
import json
from mitmproxy import http

logging.basicConfig(
    filename="browser_alerts.log",
    level=logging.WARNING,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

def emit_alert(alert_type, flow, detail=""):
    alert = {
        "type": alert_type,
        "host": flow.request.pretty_host,
        "url": flow.request.url,
        "method": flow.request.method,
        "detail": detail
    }
    with open("alerts.jsonl", "a") as f:
        f.write(json.dumps(alert) + "\n")

BLOCKED = [
    "deepseek.ai",
    "perplexity.ai",
    "huggingface.co",
    "meta.ai",
    "claude.ai",
    "chatgpt.com",
    "otter.ai,
    "character.ai",
    "sesame.com"
]

def request(flow: http.HTTPFlow):
    host = flow.request.pretty_host
    for pattern in BLOCKED:
        if pattern in flow.request.pretty_url:
            flow.response = http.Response.make(
                302,
                b"Blocked by Securty Policy, Flagged to your Security Team.",
                {"Content-Type": "text/plain"}, #Blocks Traffic
                #{"Location": "https://google.com"} #Redirect Traffic
            )
            logging.warning(f"SUSPICIOUS_DOMAIN | {host} | {flow.request.url}")
            break

def response(flow: http.HTTPFlow):
    content_length = len(flow.response.content)

    if content_length > 500_000:
        logging.warning(f"LARGE_RESPONSE | {flow.request.pretty_host} | {content_length} bytes")
        emit_alert("LARGE_RESPONSE", flow, detail=f"{content_length} bytes")

    if any(kw in flow.request.url for kw in ["token", "auth", "login", "oauth"]):
        logging.warning(f"AUTH_ENDPOINT | {flow.request.url} | {flow.response.status_code}")
        emit_alert("AUTH_ENDPOINT", flow, detail=str(flow.response.status_code))

