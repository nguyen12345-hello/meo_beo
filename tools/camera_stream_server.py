from flask import Flask, Response, jsonify, request
import cv2
import socket
import time

app = Flask(__name__)
_camera = None
_camera_index = None

def get_camera(index):
    global _camera, _camera_index
    if _camera is not None and _camera_index == index and _camera.isOpened():
        return _camera
    if _camera is not None:
        _camera.release()
    # CAP_DSHOW is generally more reliable for USB/webcams on Windows.
    cap = cv2.VideoCapture(index, cv2.CAP_DSHOW)
    if not cap.isOpened():
        cap.release()
        cap = cv2.VideoCapture(index)
    if not cap.isOpened():
        cap.release()
        return None
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    _camera, _camera_index = cap, index
    return cap

def local_ip():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.connect(("8.8.8.8", 80))
        return sock.getsockname()[0]
    except OSError:
        return "127.0.0.1"
    finally:
        sock.close()

@app.get("/")
def home():
    ip = local_ip()
    return f"""<!doctype html><html lang="vi"><meta name="viewport" content="width=device-width">
<title>Meo Beo Camera Stream</title><body style="font:16px Arial;background:#101827;color:white;padding:24px">
<h2>Camera laptop / USB</h2><p>Địa chỉ xem trên iPhone (cùng Wi-Fi):</p>
<code style="font-size:18px">http://{ip}:8080/stream</code>
<p>Đổi camera: thêm <code>?camera=1</code>, <code>?camera=2</code>...</p>
<img src="/stream" style="width:100%;max-width:900px;border-radius:16px;background:#000">
</body></html>"""

@app.get("/cameras")
def cameras():
    found = []
    for index in range(10):
        cap = cv2.VideoCapture(index, cv2.CAP_DSHOW)
        if cap.isOpened():
            ok, _ = cap.read()
            if ok:
                found.append({"index": index, "name": f"Camera {index}"})
        cap.release()
    return jsonify(found)

def generate(index):
    while True:
        cap = get_camera(index)
        if cap is None:
            time.sleep(1)
            continue
        ok, frame = cap.read()
        if not ok:
            time.sleep(0.05)
            continue
        ok, encoded = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 82])
        if ok:
            yield (b"--frame\r\nContent-Type: image/jpeg\r\n\r\n" +
                   encoded.tobytes() + b"\r\n")

@app.get("/stream")
def stream():
    try:
        index = max(0, int(request.args.get("camera", "0")))
    except ValueError:
        index = 0
    return Response(generate(index),
        mimetype="multipart/x-mixed-replace; boundary=frame",
        headers={"Cache-Control": "no-cache, no-store, must-revalidate",
                 "Pragma": "no-cache", "Access-Control-Allow-Origin": "*"})

if __name__ == "__main__":
    ip = local_ip()
    print("\nMeo Beo Camera Stream")
    print(f"Mo tren iPhone: http://{ip}:8080/stream")
    print("Nhan Ctrl+C de dung. iPhone va may tinh phai cung Wi-Fi.\n")
    app.run(host="0.0.0.0", port=8080, threaded=True)
