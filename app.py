from flask import Flask, request, jsonify
from datetime import datetime, timezone

app = Flask(__name__)

def get_client_ip():
    # Respect X-Forwarded-For if present (common when behind proxies/load balancers)
    xff = request.headers.get("X-Forwarded-For", "")
    if xff:
        # X-Forwarded-For may contain a comma-separated list; first is client
        return xff.split(",")[0].strip()
    # Fallback to remote_addr
    return request.remote_addr or ""

@app.route("/", methods=["GET"])
def index():
    ts = datetime.now(timezone.utc).astimezone().isoformat()
    return jsonify({
        "timestamp": ts,
        "ip": get_client_ip()
    })

if __name__ == "__main__":
    # For local development only; in container we'll run gunicorn
    app.run(host="0.0.0.0", port=8080)
