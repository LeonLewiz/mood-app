FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade --target=/dist-packages -r requirements.txt

FROM gcr.io/distroless/python3-debian12:nonroot AS final

WORKDIR /app

COPY --from=builder /dist-packages /usr/lib/python3/dist-packages
COPY . .

EXPOSE 8000

CMD ["app.py"]
