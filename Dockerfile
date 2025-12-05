# Use small official image
FROM python:3.11-slim

# Create non-root user and workdir
ARG USER=appuser
ARG UID=1000
ARG GID=1000

# Install build deps then remove to keep image small
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Create group and user
RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/sh ${USER} || true

WORKDIR /app

# Copy only necessary files
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip \
 && python -m pip install --no-cache-dir -r /app/requirements.txt

# Copy app code
COPY app.py /app/app.py

# Ensure app directory ownership
RUN chown -R ${USER}:${USER} /app

# Switch to non-root user
USER ${USER}

# Expose port and run with gunicorn
EXPOSE 8080
# Use gunicorn to serve Flask app: module:app (app is Flask instance in app.py)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]