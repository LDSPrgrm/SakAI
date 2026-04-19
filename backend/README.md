# SakAI Backend

> Go API server for the **SakAI** ride-hailing platform.

## Tech stack

| Layer | Technology |
|-------|------------|
| Language | Go 1.26 |
| HTTP framework | Gin |
| Database | PostgreSQL + PostGIS |
| Cache / Pub-Sub | Redis |
| API spec | OpenAPI / Swagger |

## Running the image

```bash
docker run -d \
  --name sakai-backend \
  -p 8080:8080 \
  --env-file .env \
  <namespace>/backend:latest
```

The server exposes:

| Path | Description |
|------|-------------|
| `GET /health` | Liveness probe |
| `GET /swagger/index.html` | Swagger UI |

## Environment variables

Copy [`backend/.env.example`](https://github.com/LDSPrgrm/SakAI/blob/main/backend/.env.example) and fill in the required values before starting the container.

## Source

Full source and documentation: <https://github.com/LDSPrgrm/SakAI>
