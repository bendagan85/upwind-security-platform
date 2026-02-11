from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import os

app = Flask(__name__)
CORS(app)

def get_db():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "upwind"),
        user=os.getenv("DB_USER", "upwind"),
        password=os.getenv("DB_PASSWORD", "upwind")
    )

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS servers (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            ip VARCHAR(45) NOT NULL,
            status VARCHAR(20) DEFAULT 'healthy',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.route("/api/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/api/ready")
def ready():
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.close()
        conn.close()
        return jsonify({"status": "ready"})
    except Exception as e:
        return jsonify({"status": "not ready", "error": str(e)}), 503

@app.route("/api/servers", methods=["GET"])
def get_servers():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, name, ip, status, created_at FROM servers ORDER BY id")
    servers = []
    for row in cur.fetchall():
        servers.append({
            "id": row[0],
            "name": row[1],
            "ip": row[2],
            "status": row[3],
            "created_at": row[4].isoformat()
        })
    cur.close()
    conn.close()
    return jsonify(servers)

@app.route("/api/servers", methods=["POST"])
def add_server():
    data = request.get_json()
    if not data or "name" not in data or "ip" not in data:
        return jsonify({"error": "name and ip required"}), 400
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO servers (name, ip, status) VALUES (%s, %s, %s) RETURNING id",
        (data["name"], data["ip"], data.get("status", "healthy"))
    )
    server_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"id": server_id, "message": "server added"}), 201

@app.route("/api/servers/<int:id>", methods=["DELETE"])
def delete_server(id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM servers WHERE id = %s", (id,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "server deleted"})

@app.route("/api/servers/<int:id>/status", methods=["PATCH"])
def update_status(id):
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor()
    cur.execute("UPDATE servers SET status = %s WHERE id = %s", (data["status"], id))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "status updated"})

with app.app_context():
    try:
        init_db()
    except Exception:
        pass

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)