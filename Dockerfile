
FROM python:3.13.8-slim-trixie

# Configuration Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Répertoire de travail
WORKDIR /app

# Installation des dépendances système
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Création d'un utilisateur non privilégié
RUN useradd -m appuser

# Installation des dépendances Python
# Cette étape est réalisée avant la copie du code
# afin d'optimiser le cache Docker
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source avec attribution des droits
COPY --chown=appuser:appuser . /app

# Exécution avec un utilisateur non-root
USER appuser

# Port exposé
EXPOSE 4000

# Vérification de l'état de santé de l'application
HEALTHCHECK --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD curl -f http://localhost:4000/ || exit 1

# Démarrage de l'application Flask
CMD ["python", "main.py"]
