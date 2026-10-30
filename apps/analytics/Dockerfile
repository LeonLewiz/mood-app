# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade --target=/backend-packages -r requirements.txt

FROM gcr.io/distroless/python3-debian12:nonroot AS final

WORKDIR /app

COPY --from=builder /backend-packages /usr/lib/python3/dist-packages

COPY . .

EXPOSE 8001

CMD ["app.py"]
