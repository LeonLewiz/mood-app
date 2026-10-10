# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends gcc python3-dev && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# Install dependencies
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Final image
FROM gcr.io/distroless/python3-debian12:nonroot AS final

WORKDIR /app


# Copy local libs
COPY --from=builder /root/.local /home/nonroot/.local
ENV PATH=/home/nonroot/.local/bin:$PATH
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages


COPY . .

EXPOSE 8001

CMD ["python3", "app.py"]