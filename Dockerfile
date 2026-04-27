FROM python:3.13-slim

# Étape 1 : outils de base + ajout du dépôt Chrome
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    curl \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub \
       | gpg --dearmor > /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
       > /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/*

# Étape 2 : Chrome (tire ses dépendances X11 automatiquement)
RUN apt-get update && apt-get install -y --no-install-recommends \
    google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /app

# Dépendances (couche cachée séparément du code)
# README.md requis par hatchling pour builder le package
COPY pyproject.toml uv.lock README.md ./
RUN uv sync --frozen --no-dev

COPY app/ ./app/

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
