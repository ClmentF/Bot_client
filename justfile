# Amazon Reviews Scraper — Command Runner
# Usage: just <commande>

set shell := ["bash", "-cu"]

# Afficher les commandes disponibles
default:
    @just --list

# ── Développement local ───────────────────────────────────────────────────────

# Installer les dépendances
install:
    uv sync

# Lancer l'API en mode développement (hot reload)
dev:
    uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Lancer l'API en mode production
start:
    uv run uvicorn app.main:app --host 0.0.0.0 --port 8000

# ── Qualité du code ───────────────────────────────────────────────────────────

# Linter (ruff)
lint:
    uv run ruff check app/

# Linter avec correction automatique
lint-fix:
    uv run ruff check app/ --fix

# Formatage du code
format:
    uv run ruff format app/

# Vérification des types (mypy)
typecheck:
    uv run mypy app/

# Lint + format + typecheck (séquentiel)
check:
    just lint
    just format
    just typecheck

# ── Docker ────────────────────────────────────────────────────────────────────

# Builder l'image Docker
build:
    docker compose build

# Lancer l'API via Docker (GPU activé)
up:
    @[ -f .env ] || cp .env.example .env && echo "→ .env créé depuis .env.example"
    docker compose up

# Lancer en arrière-plan
up-detached:
    docker compose up -d

# Arrêter les conteneurs
down:
    docker compose down

# Voir les logs en temps réel
logs:
    docker compose logs -f api

# Rebuild complet + relance
rebuild:
    docker compose down
    docker compose build --no-cache
    docker compose up

# ── Base de données ───────────────────────────────────────────────────────────

# Ouvrir la BDD SQLite en ligne de commande
db:
    sqlite3 data/avis_scraping.db

# Afficher le nombre d'avis par source
db-stats:
    sqlite3 data/avis_scraping.db "SELECT source, COUNT(*) as nb FROM avis GROUP BY source;"

# ── Nettoyage ─────────────────────────────────────────────────────────────────

# Supprimer les fichiers Python compilés
clean:
    find . -type d -name __pycache__ -exec rm -rf {} + || true
    find . -name "*.pyc" -delete || true
    @echo "Nettoyage terminé"

# Supprimer les exports CSV/JSON (garder la BDD)
clean-results:
    rm -rf data/results/ || true
    @echo "Exports supprimés"
