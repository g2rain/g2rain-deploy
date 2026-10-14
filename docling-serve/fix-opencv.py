"""Replace the GUI OpenCV wheel with the same headless version.

rapidocr depends on opencv-python. Reinstalling it would pull the Qt build
back and can upgrade NumPy. Packages already present in the base image stay
as they are. onnxruntime and rapidocr are installed only when metadata shows
they are absent, and that happens before the headless wheel is pinned.
"""

import subprocess
import sys

OPENCV_NAMES = (
    "opencv-python",
    "opencv-contrib-python",
    "opencv-python-headless",
    "opencv-contrib-python-headless",
)


def pip(*args):
    subprocess.check_call([sys.executable, "-m", "pip", *args])


def installed_opencv():
    code = """
import importlib.metadata as md
names = (
    "opencv-python",
    "opencv-contrib-python",
    "opencv-python-headless",
    "opencv-contrib-python-headless",
)
for name in names:
    try:
        print(f"{name}=={md.version(name)}")
    except md.PackageNotFoundError:
        pass
"""
    output = subprocess.check_output([sys.executable, "-c", code], text=True)
    found = {}
    for line in output.splitlines():
        name, version = line.split("==", 1)
        found[name] = version
    return found


def package_installed(name):
    code = (
        "import importlib.metadata as md\n"
        "try:\n"
        f"    md.version({name!r})\n"
        "except md.PackageNotFoundError:\n"
        "    raise SystemExit(1)\n"
    )
    return subprocess.call([sys.executable, "-c", code]) == 0


def ensure_pip():
    if subprocess.call([sys.executable, "-m", "pip", "--version"]) == 0:
        return
    subprocess.check_call([sys.executable, "-m", "ensurepip", "--upgrade"])


def main():
    ensure_pip()

    missing = []
    if not package_installed("onnxruntime"):
        missing.append("onnxruntime>=1.7.0,<2.0.0")
    if not package_installed("rapidocr"):
        missing.append("rapidocr>=3.9.1,<4.0.0")
    if missing:
        pip("install", "--no-cache-dir", *missing)

    found = installed_opencv()
    version = (
        found.get("opencv-python")
        or found.get("opencv-contrib-python")
        or found.get("opencv-python-headless")
        or found.get("opencv-contrib-python-headless")
    )
    if not version:
        raise SystemExit("base image has no opencv distribution")

    present = [name for name in OPENCV_NAMES if name in found]
    if present:
        pip("uninstall", "-y", *present)
    pip(
        "install",
        "--no-cache-dir",
        "--no-deps",
        f"opencv-python-headless=={version}",
    )

    verify = r"""
import importlib.metadata as md
import cv2
import onnxruntime
from rapidocr import RapidOCR

names = (
    "opencv-python",
    "opencv-contrib-python",
    "opencv-python-headless",
    "opencv-contrib-python-headless",
)
installed = []
for name in names:
    try:
        md.version(name)
        installed.append(name)
    except md.PackageNotFoundError:
        pass
if installed != ["opencv-python-headless"]:
    raise SystemExit(f"unexpected opencv packages: {installed}")

gui = next(
    (
        line.split(":", 1)[1].strip()
        for line in cv2.getBuildInformation().splitlines()
        if line.strip().startswith("GUI:")
    ),
    "",
)
if gui.upper() != "NONE":
    raise SystemExit(f"OpenCV is not headless: GUI={gui!r}")
if onnxruntime.get_device() != "CPU":
    raise SystemExit(f"onnxruntime device is {onnxruntime.get_device()}")
print("opencv", cv2.__version__, "gui", gui)
print("onnxruntime", onnxruntime.__version__, onnxruntime.get_device())
print("rapidocr", RapidOCR)
"""
    subprocess.check_call([sys.executable, "-c", verify])


if __name__ == "__main__":
    main()
