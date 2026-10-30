FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade -r requirements.txt

FROM gcr.io/distroless/python3-debian12:nonroot AS final

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

COPY . .

EXPOSE 8000
CMD ["app.py"]
