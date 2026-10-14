# 官方 CPU 镜像已含 Docling、TableFormer 与模型权重。此处只替换 OpenCV，避免旧内核无法加载 Qt。
ARG BASE_IMAGE=ghcr.io/docling-project/docling-serve-cpu:v1.29.0
FROM ${BASE_IMAGE}

COPY fix-opencv.py /tmp/fix-opencv.py
RUN python3 /tmp/fix-opencv.py && rm -f /tmp/fix-opencv.py
