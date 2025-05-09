# # Use the official slim Python image
# # FROM python:3.10-slim
# FROM python:3.12-alpine3.20

# # Set a working directory
# WORKDIR /app

# # Install system-level dependencies (for psycopg2, etc.)
# RUN apt-get update && \
#     apt-get install -y build-essential libpq-dev && \
#     rm -rf /var/lib/apt/lists/*

# # Copy requirements and install
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# # Copy your code in
# COPY . .

# # Collect static files (if you have any)
# RUN python manage.py collectstatic --noinput

# # Expose the port Django will run on
# EXPOSE 8000

# # Default command: run Django’s dev server (we’ll override in production)
# CMD ["gunicorn", "microservice.wsgi:application", "--bind", "0.0.0.0:8000"]



FROM python:3.12-alpine3.20
WORKDIR /app

# install the compiler toolchain and Postgres headers
RUN apk add --no-cache \
      build-base \
      postgresql-dev \
      python3-dev

# now copy requirements and install your Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy the rest of your code
COPY . .

# collect static files, expose port, etc.
RUN python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["gunicorn", "microservice.wsgi:application", "--bind", "0.0.0.0:8000"]
