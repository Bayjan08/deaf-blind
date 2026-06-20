# Deaf-Blind API (backend)

FastAPI backend, deployed to Google Cloud Run.

## Run locally

```bash
cd deaf-blind-backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # then edit values
uvicorn main:app --reload --port 9000
```

- API:  http://localhost:9000
- Docs: http://localhost:9000/docs  (dev only)
- Health: http://localhost:9000/health

## Environments

| Branch | Cloud Run service       | Purpose          |
|--------|-------------------------|------------------|
| `dev`  | `deaf-blind-api-dev`    | testing / shared |
| `main` | `deaf-blind-api-prod`   | production       |

Push to `dev` or `main` and GitHub Actions auto-deploys (see
`.github/workflows/deploy-backend.yml`).

## First-time deploy (manual, one command)

Make sure gcloud is installed and you've run `gcloud auth login` and
`gcloud config set project YOUR_GCP_PROJECT_ID`.

```bash
# Dev service
gcloud run deploy deaf-blind-api-dev \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars ENV=dev

# Prod service
gcloud run deploy deaf-blind-api-prod \
  --source . \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars ENV=prod
```

Cloud Run builds the Dockerfile for you and gives back a public URL — put the
**dev** URL in your mobile app while building.

## Secrets

Set per-environment env vars on each Cloud Run service (Console → service →
Edit → Variables), e.g. `DATABASE_URL`, `OPENAI_API_KEY`. Never commit `.env`.
