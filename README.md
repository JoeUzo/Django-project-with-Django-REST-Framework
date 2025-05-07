# Django REST + Celery Microservice

A microservice built with Django REST Framework and Celery for asynchronous task processing.

## Overview

This project demonstrates a production-ready microservice architecture with:

- Django REST Framework API endpoints
- Asynchronous task processing with Celery
- Redis as a message broker and result backend
- PostgreSQL database (via Docker)
- Docker containerization for all services

## Architecture

The project consists of the following components:

- **Web Service**: Django REST Framework application exposing API endpoints
- **Worker Service**: Celery worker processing background tasks
- **Redis**: Message broker for task queue communication
- **PostgreSQL**: Persistent database storage

## Features

- RESTful API endpoints for submitting processing requests
- Asynchronous task execution
- Task status tracking and result retrieval
- Containerized services with Docker and Docker Compose
- Environment-based configuration

## API Endpoints

### Submit Processing Request
```
POST /api/process/
```
**Payload:**
```json
{
  "email": "user@example.com",
  "message": "Your message to process"
}
```
**Response:**
```json
{
  "task_id": "task-uuid-here"
}
```

### Check Task Status
```
GET /api/status/<task_id>/
```
**Response:**
```json
{
  "task_id": "task-uuid-here",
  "status": "SUCCESS",
  "result": "Done for user@example.com: Your message to process"
}
```

## Setup Instructions

### Prerequisites
- Docker and Docker Compose

### Environment Configuration
Create a `.env` file in the project root with the following variables:
```
# Django
DEBUG=False
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DATABASE_URL=postgres://postgres:postgres@db:5432/postgres
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# Celery
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0
```

### Running the Application

1. Start all services:
   ```bash
   docker-compose up -d
   ```

2. Run migrations:
   ```bash
   docker-compose exec web python manage.py migrate
   ```

3. Create a superuser (optional):
   ```bash
   docker-compose exec web python manage.py createsuperuser
   ```

## Development

### Local Setup

1. Create a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run migrations:
   ```bash
   python manage.py migrate
   ```

4. Start the development server:
   ```bash
   python manage.py runserver
   ```

5. Start a Celery worker:
   ```bash
   celery -A microservice worker --loglevel=info
   ```

## Testing

Run the tests with:
```bash
python manage.py test
```

## Deployment

The application is containerized and ready for deployment. For production, consider:

1. Using a managed PostgreSQL database
2. Setting up proper logging and monitoring
3. Implementing SSL/TLS
4. Setting appropriate resource limits for containers

## License

[MIT License](LICENSE) 