# Use the official slim Python image
FROM python:3.10-slim

# Set a working directory
WORKDIR /app

# Install system-level dependencies (for psycopg2, etc.)
RUN apt-get update && \
    apt-get install -y build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your code in
COPY . .

# Collect static files (if you have any)
RUN python manage.py collectstatic --noinput

# Expose the port Django will run on
EXPOSE 8000

# Default command: run Django’s dev server (we’ll override in production)
CMD ["gunicorn", "microservice.wsgi:application", "--bind", "0.0.0.0:8000"]
