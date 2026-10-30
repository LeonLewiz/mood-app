# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /build

RUN apt-get update && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# Install dependencies
RUN pip install --no-cache-dir --upgrade --user -r requirements.txt

# Stage 2: Final image
FROM gcr.io/distroless/python3-debian12:nonroot AS final

WORKDIR /app


# Copy local libs
COPY --from=builder /root/.local /home/nonroot/.local
ENV PATH=/home/nonroot/.local/bin:$PATH
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages


COPY . .

EXPOSE 8001

CMD ["app.py"]