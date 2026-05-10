#!/usr/bin/env python3
"""
Single-port multi-project doc server with interactive CRUD web UI.

Serves every registered project under its own path prefix on one port.
Landing page at / provides an interactive UI to add, edit, and remove projects.

Usage:
  python3 docserver.py serve                     # start the server
  python3 docserver.py add --dir <path> --name <name>  # register a project
  python3 docserver.py remove --name <name>      # unregister
  python3 docserver.py list                      # list registered projects

Config file (routes.conf alongside this script):
  cacheagent  /data/home/liz/CacheAgent/docs/html
  myproject   /home/liz/other-project/docs/html
"""

import argparse
import json
import os
import re
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from socketserver import ThreadingMixIn


class ThreadingHTTPServer(ThreadingMixIn, HTTPServer):
    """Threaded HTTP server that handles each request in a new thread."""
    daemon_threads = True
from pathlib import Path
from urllib.parse import unquote

SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG = SCRIPT_DIR / "routes.conf"


def load_routes():
    """Parse routes.conf into {name: doc_dir}."""
    routes = {}
    if CONFIG.exists():
        for line in CONFIG.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split(maxsplit=1)
            if len(parts) == 2:
                routes[parts[0]] = Path(parts[1]).expanduser().resolve()
    return routes


def save_routes(routes):
    """Persist routes to config file."""
    lines = [f"{name}  {path}" for name, path in sorted(routes.items())]
    CONFIG.write_text("\n".join(lines) + "\n")


def landing_page(port):
    """Generate the interactive landing page listing all projects."""
    return f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>DocServer — Projects</title>
<style>
:root {{
  --bg:#171411;--bg-deeper:#12100d;--surface:#201d18;--surface-hi:#28251f;
  --border:#332e27;--border-hi:#4a3f30;--text:#dbd4c7;--text-hi:#ede7dc;
  --muted:#8a8276;--accent:#d49528;--accent-glow:#f0b840;--green:#7a9e48;
  --green-dim:#2a3818;--red:#c55542;--radius:6px;--radius-lg:10px;
  --font-body:"Noto Sans SC","PingFang SC","Microsoft YaHei",system-ui,sans-serif;
  --font-mono:"JetBrains Mono","Cascadia Code","Fira Code",monospace;
}}
*,*::before,*::after{{box-sizing:border-box;margin:0;padding:0}}
body{{
  font-family:var(--font-body);background:var(--bg);color:var(--text);
  min-height:100vh;max-width:800px;margin:0 auto;padding:3rem 1.75rem 4rem;
  line-height:1.72;-webkit-font-smoothing:antialiased;
}}
body::after{{
  content:'';position:fixed;top:0;left:0;right:0;height:2px;z-index:99999;pointer-events:none;
  background:linear-gradient(90deg,transparent,var(--accent),transparent);
  animation:pulse 4s ease-in-out infinite;
}}
@keyframes pulse{{0%,100%{{opacity:.6}}50%{{opacity:1}}}}

h1{{font-size:1.8rem;font-weight:700;color:var(--text-hi);margin:0}}
h1::before{{content:'';display:inline-block;width:4px;height:1.1em;background:var(--accent);
  border-radius:2px;margin-right:.55rem;vertical-align:text-bottom}}
p.sub{{color:var(--muted);margin-bottom:2rem}}

/* Action bar */
.action-bar{{display:flex;justify-content:space-between;align-items:center;margin-bottom:.5rem}}

/* Buttons */
.btn{{padding:8px 18px;border-radius:var(--radius);border:1px solid transparent;
  font-family:var(--font-body);font-size:.88rem;cursor:pointer;transition:all .18s;
  display:inline-flex;align-items:center;gap:6px;line-height:1.4}}
.btn:hover{{transform:translateY(-1px)}}
.btn:active{{transform:translateY(0)}}
.btn:disabled{{opacity:.5;cursor:not-allowed;transform:none}}
.btn-primary{{background:var(--accent);color:#171411;border-color:var(--accent);font-weight:600}}
.btn-primary:hover{{background:var(--accent-glow);box-shadow:0 2px 12px rgba(212,149,40,.25)}}
.btn-danger{{background:var(--red);color:#fff;font-weight:600}}
.btn-danger:hover{{box-shadow:0 2px 12px rgba(197,85,66,.3)}}
.btn-ghost{{background:transparent;border-color:var(--border);color:var(--muted)}}
.btn-ghost:hover{{border-color:var(--border-hi);color:var(--text)}}
.btn-sm{{padding:4px 12px;font-size:.8rem}}
.btn-icon{{background:none;border:none;color:var(--muted);cursor:pointer;padding:4px 8px;
  font-size:1rem;border-radius:var(--radius);transition:all .15s}}
.btn-icon:hover{{color:var(--accent-glow);background:rgba(212,149,40,.06)}}
.btn-icon.danger:hover{{color:var(--red);background:rgba(197,85,66,.06)}}

/* Table */
table{{width:100%;border-collapse:collapse;margin:1rem 0}}
th,td{{border:1px solid var(--border);padding:.55rem .85rem;text-align:left}}
th{{background:var(--surface);font-weight:600;color:var(--text-hi);font-size:.82rem;
  text-transform:uppercase;letter-spacing:.05em}}
tr:nth-child(even){{background:rgba(255,255,255,.012)}}
tr:hover{{background:rgba(212,149,40,.03)}}
td.path{{font-family:var(--font-mono);font-size:.82rem;color:var(--muted);word-break:break-all}}
td.status{{text-align:center}}
td.actions{{text-align:right;white-space:nowrap}}
.status-ok{{color:var(--green)}}
.status-missing{{color:var(--red)}}
.empty-row td{{text-align:center;color:var(--muted);padding:2rem}}

a{{color:var(--accent);text-decoration:none;transition:color .18s}}
a:hover{{color:var(--accent-glow)}}
code{{background:#1c1915;padding:.15em .4em;border-radius:3px;font-family:var(--font-mono);
  font-size:.86em;border:1px solid rgba(255,255,255,.04)}}

/* Modal overlay */
.modal-overlay{{position:fixed;top:0;left:0;right:0;bottom:0;
  background:rgba(0,0,0,.6);backdrop-filter:blur(4px);z-index:10000;
  display:flex;align-items:center;justify-content:center}}
.modal-overlay.hidden{{display:none}}
.modal{{background:var(--surface);border:1px solid var(--border-hi);
  border-radius:var(--radius-lg);padding:1.5rem;width:90%;max-width:460px;
  box-shadow:0 8px 40px rgba(0,0,0,.5);animation:modalIn .2s ease-out}}
@keyframes modalIn{{from{{opacity:0;transform:translateY(-10px) scale(.97)}}
  to{{opacity:1;transform:translateY(0) scale(1)}}}}
.modal-header{{display:flex;justify-content:space-between;align-items:center;
  margin-bottom:1.25rem;padding-bottom:.75rem;border-bottom:1px solid var(--border)}}
.modal-header h2{{font-size:1.15rem;color:var(--text-hi);font-weight:600}}
.btn-close{{background:none;border:none;color:var(--muted);font-size:1.4rem;
  cursor:pointer;padding:0 4px;line-height:1;transition:color .15s}}
.btn-close:hover{{color:var(--text)}}

/* Forms */
.form-group{{margin-bottom:1rem}}
.form-label{{display:block;font-size:.82rem;color:var(--muted);margin-bottom:.35rem;
  font-weight:500;text-transform:uppercase;letter-spacing:.04em}}
.form-input{{width:100%;background:var(--bg);border:1px solid var(--border);
  border-radius:var(--radius);padding:9px 12px;color:var(--text);
  font-family:var(--font-mono);font-size:.88rem;transition:border-color .18s}}
.form-input:focus{{outline:none;border-color:var(--accent);box-shadow:0 0 0 3px rgba(212,149,40,.1)}}
.form-input::placeholder{{color:var(--muted);opacity:.5}}
.form-actions{{display:flex;justify-content:flex-end;gap:10px;margin-top:1.5rem}}

/* Delete modal */
.delete-modal{{max-width:380px;text-align:center}}
.delete-modal p{{margin:1rem 0;color:var(--text);line-height:1.6}}
.delete-modal strong{{color:var(--text-hi)}}

/* Toasts */
#toast-container{{position:fixed;bottom:24px;right:24px;z-index:99999;
  display:flex;flex-direction:column;gap:8px;max-width:360px}}
.toast{{padding:12px 20px;border-radius:var(--radius);border:1px solid var(--border);
  background:var(--surface);color:var(--text);font-size:.88rem;
  animation:slideIn .25s ease-out;box-shadow:0 4px 20px rgba(0,0,0,.4);
  display:flex;align-items:center;gap:8px}}
.toast-success{{border-left:3px solid var(--green)}}
.toast-error{{border-left:3px solid var(--red)}}
.toast.fade-out{{animation:fadeOut .3s ease-in forwards}}
@keyframes slideIn{{from{{opacity:0;transform:translateX(100px)}}to{{opacity:1;transform:translateX(0)}}}}
@keyframes fadeOut{{from{{opacity:1}}to{{opacity:0;transform:translateX(40px)}}}}

/* SSH hint */
.hint{{background:var(--surface);border:1px solid var(--border);
  border-radius:var(--radius-lg);padding:1rem 1.25rem;margin:1.5rem 0;font-size:.88rem}}
.hint code{{color:var(--accent)}}
footer{{margin-top:3rem;padding-top:1rem;border-top:1px solid var(--border);
  color:var(--muted);font-size:.8rem}}
</style>
</head>
<body>
<div id="app">
  <div class="action-bar">
    <h1>DocServer</h1>
    <button id="btn-add" class="btn btn-primary">+ Add Project</button>
  </div>
  <p class="sub">Port {port} &middot; <span id="project-count">0</span> projects</p>
  <table>
    <thead>
      <tr><th>Project</th><th>Path</th><th style="width:60px">Status</th><th style="width:100px">Actions</th></tr>
    </thead>
    <tbody id="projects-tbody"></tbody>
  </table>
  <div class="hint">
    SSH tunnel: <code>ssh -L {port}:127.0.0.1:{port} -N user@server</code>
  </div>
  <footer>DocServer — interactive project management</footer>
</div>

<!-- Add/Edit Modal -->
<div id="project-modal" class="modal-overlay hidden">
  <div class="modal">
    <div class="modal-header">
      <h2 id="modal-title">Add Project</h2>
      <button id="modal-close" class="btn-close">&times;</button>
    </div>
    <form id="project-form">
      <input type="hidden" id="form-original-name">
      <div class="form-group">
        <label class="form-label" for="form-name">Project Name</label>
        <input class="form-input" id="form-name" type="text" required
          pattern="[a-zA-Z0-9_-]+" placeholder="my-project" minlength="1" maxlength="64">
      </div>
      <div class="form-group">
        <label class="form-label" for="form-dir">Directory Path</label>
        <input class="form-input" id="form-dir" type="text" required
          placeholder="/home/user/project/docs/html">
      </div>
      <div class="form-actions">
        <button type="button" class="btn btn-ghost" id="modal-cancel">Cancel</button>
        <button type="submit" class="btn btn-primary" id="modal-submit">Save</button>
      </div>
    </form>
  </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="delete-modal" class="modal-overlay hidden">
  <div class="modal delete-modal">
    <div class="modal-header">
      <h2>Confirm Delete</h2>
    </div>
    <p>Remove project <strong id="delete-name"></strong> from the server?</p>
    <p style="font-size:.82rem;color:var(--muted)">Documentation files on disk are not affected.</p>
    <div class="form-actions" style="justify-content:center">
      <button class="btn btn-ghost" id="delete-cancel">Cancel</button>
      <button class="btn btn-danger" id="delete-confirm">Delete</button>
    </div>
  </div>
</div>

<!-- Toast Container -->
<div id="toast-container"></div>

<script>
let projects = [];
let editingName = null;

// --- API calls ---

async function apiRequest(method, path, body) {{
  const opts = {{method, headers:{{'Content-Type':'application/json'}}}};
  if (body) opts.body = JSON.stringify(body);
  const res = await fetch(path, opts);
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Request failed');
  return data;
}}

async function fetchProjects() {{
  try {{
    const data = await apiRequest('GET', '/api/projects');
    // API returns {{name: path}} — convert to array
    projects = Object.entries(data).map(([name, details]) => ({{
      name,
      path: details.path,
      exists: details.exists
    }}));
    renderTable();
  }} catch (e) {{
    showToast(e.message, 'error');
  }}
}}

async function addProject(name, dir) {{
  return apiRequest('POST', '/api/projects', {{name, dir}});
}}

async function updateProject(originalName, name, dir) {{
  return apiRequest('PUT', '/api/projects/' + encodeURIComponent(originalName),
    {{name, dir}});
}}

async function deleteProject(name) {{
  return apiRequest('DELETE', '/api/projects/' + encodeURIComponent(name));
}}

// --- Table rendering ---

function renderTable() {{
  const tbody = document.getElementById('projects-tbody');
  const countEl = document.getElementById('project-count');
  countEl.textContent = projects.length;

  if (projects.length === 0) {{
    tbody.innerHTML = '<tr class="empty-row"><td colspan="4">No projects registered. Click "+ Add Project" to get started.</td></tr>';
    return;
  }}

  tbody.innerHTML = projects.map(p => {{
    const statusIcon = p.exists
      ? '<span class="status-ok" title="Directory exists">&#x2713;</span>'
      : '<span class="status-missing" title="Directory missing">&#x2717;</span>';
    return `<tr>
      <td><a href="/${{p.name}}/">${{p.name}}</a></td>
      <td class="path">${{p.path}}</td>
      <td class="status">${{statusIcon}}</td>
      <td class="actions">
        <button class="btn-icon" onclick="openEditModal('${{p.name}}')" title="Edit">&#x270E;</button>
        <button class="btn-icon danger" onclick="openDeleteModal('${{p.name}}')" title="Delete">&#x2715;</button>
      </td>
    </tr>`;
  }}).join('');
}}

// --- Modals ---

function openAddModal() {{
  editingName = null;
  document.getElementById('modal-title').textContent = 'Add Project';
  document.getElementById('form-original-name').value = '';
  document.getElementById('form-name').value = '';
  document.getElementById('form-name').disabled = false;
  document.getElementById('form-dir').value = '';
  document.getElementById('project-modal').classList.remove('hidden');
  document.getElementById('form-name').focus();
}}

function openEditModal(name) {{
  const p = projects.find(p => p.name === name);
  if (!p) return;
  editingName = name;
  document.getElementById('modal-title').textContent = 'Edit Project';
  document.getElementById('form-original-name').value = name;
  document.getElementById('form-name').value = p.name;
  document.getElementById('form-name').disabled = true;
  document.getElementById('form-dir').value = p.path;
  document.getElementById('project-modal').classList.remove('hidden');
  document.getElementById('form-dir').focus();
}}

function closeProjectModal() {{
  document.getElementById('project-modal').classList.add('hidden');
  document.getElementById('project-form').reset();
}}

function openDeleteModal(name) {{
  document.getElementById('delete-name').textContent = name;
  document.getElementById('delete-modal').classList.remove('hidden');
  document.getElementById('delete-modal')._deleteName = name;
}}

function closeDeleteModal() {{
  document.getElementById('delete-modal').classList.add('hidden');
}}

// --- Toast ---

function showToast(message, type) {{
  const container = document.getElementById('toast-container');
  const toast = document.createElement('div');
  toast.className = 'toast toast-' + type;
  toast.textContent = message;
  container.appendChild(toast);
  setTimeout(() => {{
    toast.classList.add('fade-out');
    setTimeout(() => toast.remove(), 300);
  }}, 3000);
}}

// --- Form submit ---

document.getElementById('project-form').addEventListener('submit', async (e) => {{
  e.preventDefault();
  const name = document.getElementById('form-name').value.trim();
  const dir = document.getElementById('form-dir').value.trim();
  const submitBtn = document.getElementById('modal-submit');

  if (!name || !dir) return;
  submitBtn.disabled = true;
  submitBtn.textContent = 'Saving...';

  try {{
    if (editingName) {{
      await updateProject(editingName, name, dir);
      showToast('Project updated: ' + name, 'success');
    }} else {{
      await addProject(name, dir);
      showToast('Project added: ' + name, 'success');
    }}
    closeProjectModal();
    await fetchProjects();
  }} catch (err) {{
    showToast(err.message, 'error');
  }} finally {{
    submitBtn.disabled = false;
    submitBtn.textContent = 'Save';
  }}
}});

// --- Delete confirm ---

document.getElementById('delete-confirm').addEventListener('click', async () => {{
  const name = document.getElementById('delete-modal')._deleteName;
  if (!name) return;
  const btn = document.getElementById('delete-confirm');
  btn.disabled = true;
  btn.textContent = 'Deleting...';

  try {{
    await deleteProject(name);
    showToast('Project removed: ' + name, 'success');
    closeDeleteModal();
    await fetchProjects();
  }} catch (err) {{
    showToast(err.message, 'error');
  }} finally {{
    btn.disabled = false;
    btn.textContent = 'Delete';
  }}
}});

// --- Modal close handlers ---

document.getElementById('modal-close').addEventListener('click', closeProjectModal);
document.getElementById('modal-cancel').addEventListener('click', closeProjectModal);
document.getElementById('delete-cancel').addEventListener('click', closeDeleteModal);

// Close modals on overlay click
document.getElementById('project-modal').addEventListener('click', function(e) {{
  if (e.target === this) closeProjectModal();
}});
document.getElementById('delete-modal').addEventListener('click', function(e) {{
  if (e.target === this) closeDeleteModal();
}});

// Close modals on Escape
document.addEventListener('keydown', function(e) {{
  if (e.key === 'Escape') {{
    if (!document.getElementById('project-modal').classList.contains('hidden'))
      closeProjectModal();
    if (!document.getElementById('delete-modal').classList.contains('hidden'))
      closeDeleteModal();
  }}
}});

// --- Add button ---

document.getElementById('btn-add').addEventListener('click', openAddModal);

// --- Initial load ---

fetchProjects();
</script>
</body>
</html>"""


class DocServerHandler(SimpleHTTPRequestHandler):
    """Serve / as landing page, /api/projects as JSON API, /<project>/ from mapped doc dir."""

    protocol_version = "HTTP/1.0"  # Avoid keep-alive connection reuse issues
    routes = {}
    port = 8080
    _max_body = 64 * 1024  # 64KB max request body

    # ── HTTP method dispatch ──────────────────────────────────────────

    def do_GET(self):
        try:
            path = unquote(self.path)

            if path == "/api/projects":
                return self._handle_api_list()

            if path == "/" or path == "/index.html":
                self._serve_html(landing_page(self.port))
                return

            match = re.match(r"^/([^/]+)(/.*)?$", path)
            if match:
                name = match.group(1)
                subpath = match.group(2) or "/"
                if name in self.routes:
                    self._serve_project(self.routes[name], subpath)
                    return

            self.send_error(404, f"Unknown project or path: {path}")
        except Exception:
            self.send_error(500)

    def do_POST(self):
        try:
            path = unquote(self.path)
            if path == "/api/projects":
                return self._handle_api_add()
            self.send_error(405, "Method not allowed")
        except Exception:
            self.send_error(500)

    def do_PUT(self):
        try:
            path = unquote(self.path)
            match = re.match(r"^/api/projects/([^/]+)$", path)
            if match:
                return self._handle_api_update(unquote(match.group(1)))
            self.send_error(405, "Method not allowed")
        except Exception:
            self.send_error(500)

    def do_DELETE(self):
        try:
            path = unquote(self.path)
            match = re.match(r"^/api/projects/([^/]+)$", path)
            if match:
                return self._handle_api_delete(unquote(match.group(1)))
            self.send_error(405, "Method not allowed")
        except Exception:
            self.send_error(500)

    # ── JSON helpers ──────────────────────────────────────────────────

    def _send_json(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def _read_json_body(self):
        length = int(self.headers.get("Content-Length", 0))
        if length == 0:
            return None
        if length > self._max_body:
            self._send_json({"error": "Request body too large"}, 413)
            return None
        try:
            raw = self.rfile.read(length)
            return json.loads(raw)
        except (json.JSONDecodeError, UnicodeDecodeError):
            self._send_json({"error": "Invalid JSON"}, 400)
            return None

    # ── API handlers ──────────────────────────────────────────────────

    def _handle_api_list(self):
        result = {}
        for name, path in sorted(self.routes.items()):
            result[name] = {"path": str(path), "exists": path.is_dir()}
        self._send_json(result)

    def _handle_api_add(self):
        body = self._read_json_body()
        if body is None:
            return

        name = (body.get("name") or "").strip()
        directory = (body.get("dir") or "").strip()

        if not name:
            self._send_json({"error": "Project name is required"}, 400)
            return
        if not re.match(r"^[a-zA-Z0-9_-]+$", name):
            self._send_json({"error": "Invalid project name (use a-z, 0-9, -, _)"}, 400)
            return
        if not directory:
            self._send_json({"error": "Directory path is required"}, 400)
            return

        # Reload to get latest state
        routes = load_routes()
        if name in routes:
            self._send_json({"error": f"Project already exists: {name}"}, 409)
            return

        doc_dir = Path(directory).expanduser().resolve()
        routes[name] = doc_dir
        save_routes(routes)
        DocServerHandler.routes = routes

        self._send_json({"name": name, "path": str(doc_dir), "exists": doc_dir.is_dir()}, 201)

    def _handle_api_update(self, name):
        body = self._read_json_body()
        if body is None:
            return

        new_name = (body.get("name") or "").strip()
        directory = (body.get("dir") or "").strip()

        if not directory:
            self._send_json({"error": "Directory path is required"}, 400)
            return

        routes = load_routes()
        if name not in routes:
            self._send_json({"error": f"Project not found: {name}"}, 404)
            return

        doc_dir = Path(directory).expanduser().resolve()

        # Handle rename
        if new_name and new_name != name:
            if not re.match(r"^[a-zA-Z0-9_-]+$", new_name):
                self._send_json({"error": "Invalid project name (use a-z, 0-9, -, _)"}, 400)
                return
            if new_name in routes:
                self._send_json({"error": f"Project already exists: {new_name}"}, 409)
                return
            del routes[name]
            routes[new_name] = doc_dir
        else:
            routes[name] = doc_dir

        save_routes(routes)
        DocServerHandler.routes = routes

        final_name = new_name if (new_name and new_name != name) else name
        self._send_json({"name": final_name, "path": str(doc_dir), "exists": doc_dir.is_dir()})

    def _handle_api_delete(self, name):
        routes = load_routes()
        if name not in routes:
            self._send_json({"error": f"Project not found: {name}"}, 404)
            return

        del routes[name]
        save_routes(routes)
        DocServerHandler.routes = routes

        self._send_json({"success": True})

    # ── Static file serving ───────────────────────────────────────────

    def _serve_project(self, doc_dir, subpath):
        safe = subpath.lstrip("/")
        filepath = (doc_dir / safe).resolve()
        if not str(filepath).startswith(str(doc_dir)):
            self.send_error(403, "Path traversal denied")
            return

        if filepath.is_dir():
            filepath = filepath / "index.html"

        if not filepath.is_file():
            self.send_error(404, f"File not found: {safe}")
            return

        content_type = self._guess_type(str(filepath))
        try:
            data = filepath.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(data)
        except OSError:
            self.send_error(500, "Failed to read file")

    def _serve_html(self, html):
        data = html.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(data)

    def _guess_type(self, path):
        ext = path.rsplit(".", 1)[-1].lower() if "." in path else ""
        return {
            "html": "text/html; charset=utf-8",
            "css": "text/css",
            "js": "application/javascript",
            "json": "application/json",
            "png": "image/png",
            "svg": "image/svg+xml",
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "gif": "image/gif",
            "ico": "image/x-icon",
            "woff2": "font/woff2",
            "md": "text/markdown; charset=utf-8",
        }.get(ext, "application/octet-stream")

    def log_message(self, format, *args):
        name = ""
        match = re.match(r"^/([^/]+)", getattr(self, "path", ""))
        if match and match.group(1) in self.routes:
            name = f" [{match.group(1)}]"
        print(f"  {args[0]}{name}", flush=True)


# ── CLI commands ──────────────────────────────────────────────────────


def cmd_add(args):
    doc_dir = Path(args.dir).expanduser().resolve()
    if not doc_dir.is_dir():
        print(f"Error: directory not found: {doc_dir}")
        sys.exit(1)
    routes = load_routes()
    routes[args.name] = doc_dir
    save_routes(routes)
    print(f"Registered: {args.name} -> {doc_dir}")


def cmd_remove(args):
    routes = load_routes()
    if args.name in routes:
        del routes[args.name]
        save_routes(routes)
        print(f"Removed: {args.name}")
    else:
        print(f"Not found: {args.name}")


def cmd_list(args):
    routes = load_routes()
    if not routes:
        print("No projects registered. Use --add to register one.")
        return
    print(f"{'Project':<20} {'Path'}")
    print("-" * 60)
    for name, path in sorted(routes.items()):
        status = "ok" if path.is_dir() else "missing"
        print(f"{name:<20} {path}  ({status})")


def cmd_serve(args):
    routes = load_routes()
    if not routes:
        print("No projects registered. Auto-discovering from current directory...")
        cwd = Path.cwd()
        html_dir = cwd / "docs" / "html"
        if html_dir.is_dir():
            name = cwd.name
            routes[name] = html_dir.resolve()
            save_routes(routes)
            print(f"  Auto-registered: {name} -> {html_dir}")
        else:
            print("  No docs/html/ found in current directory.")
            print("  Use: python3 docserver.py add --dir <dir> --name <name>")
            sys.exit(1)

    port = args.port
    DocServerHandler.routes = routes
    DocServerHandler.port = port

    server = ThreadingHTTPServer(("0.0.0.0", port), DocServerHandler)
    print(f"DocServer listening on :{port}")
    print(f"  Landing:  http://localhost:{port}/")
    for name in sorted(routes):
        print(f"  Project:  http://localhost:{port}/{name}/")
    print(f"  SSH:      ssh -L {port}:127.0.0.1:{port} -N user@server")
    print("  Ctrl+C to stop")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        server.shutdown()


def main():
    parser = argparse.ArgumentParser(description="Single-port multi-project doc server")
    sub = parser.add_subparsers(dest="command", help="Commands")

    serve = sub.add_parser("serve", help="Start the server (default)")
    serve.add_argument("--port", type=int, default=8080)

    add = sub.add_parser("add", help="Register a project")
    add.add_argument("--dir", required=True)
    add.add_argument("--name", required=True)

    rm = sub.add_parser("remove", help="Unregister a project")
    rm.add_argument("--name", required=True)

    sub.add_parser("list", help="List registered projects")

    args = parser.parse_args()

    if args.command == "add":
        cmd_add(args)
    elif args.command == "remove":
        cmd_remove(args)
    elif args.command == "list":
        cmd_list(args)
    else:
        class ServeArgs:
            port = getattr(args, 'port', 8080)
        cmd_serve(ServeArgs())


if __name__ == "__main__":
    main()
