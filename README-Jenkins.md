# Production CI/CD Pipeline with Jenkins

This guide explains how to set up the production-level Jenkins CI/CD pipeline for deploying the microservice application.

## Prerequisites

- Jenkins server with the following plugins installed:
  - Pipeline
  - Git
  - Credentials Binding
  - Slack Notification
- Docker and Docker Compose installed on Jenkins nodes
- Access to Docker Registry
- Slack workspace configured for notifications

## Credentials Setup

### 1. Environment Variables

Create separate environment credentials for each deployment environment:

1. In Jenkins, go to **Manage Jenkins** > **Credentials** > **System** > **Global credentials**
2. Click **Add Credentials**
3. Select **Secret text** as the kind
4. In the **Secret** field, paste the entire content of your environment-specific `.env` file
5. Set **ID** to:
   - `env-file-dev` for development environment
   - `env-file-staging` for staging environment
   - `env-file-production` for production environment
6. Add a description and click **OK**

### 2. Docker Registry Credentials

1. Create Docker registry credentials:
   - **ID**: `docker-credentials`
   - **Kind**: Username with password
   - **Username**: Your Docker registry username
   - **Password**: Your Docker registry password

2. Create Docker registry URL:
   - **ID**: `docker-registry-url`
   - **Kind**: Secret text
   - **Secret**: Your Docker registry URL (e.g., docker.io, gcr.io)

### 3. Slack Notification Setup

1. In your Slack workspace, create a webhook for Jenkins integration
2. In Jenkins, configure the Slack Notification plugin with your workspace and credentials

## Pipeline Configuration

1. Create a new Jenkins Pipeline job
2. Configure source code management to point to your Git repository
3. Set the **Script Path** to `Jenkinsfile`
4. Configure branch sources if using multibranch pipeline
5. Set up webhook triggers from your Git provider to Jenkins

## Running the Pipeline

When running the pipeline, you'll be prompted to select:

- **ENVIRONMENT**: Choose between `dev`, `staging`, or `production`
- **ACTION**: Choose between `up` (deploy) or `down` (undeploy)
- **DETACHED**: Run containers in detached mode (recommended for production)

## Pipeline Stages

The pipeline includes the following stages:

1. **Checkout**: Retrieves source code and sets build version
2. **Create Environment Config**: Creates environment-specific .env file
3. **Validate Compose File**: Validates docker-compose.yaml syntax
4. **Docker Login**: Authenticates with Docker registry
5. **Pull Latest Images**: Pulls the latest Docker images
6. **Apply Database Migrations**: Runs database migrations
7. **Deploy**: Deploys or undeploys the services
8. **Post-Actions**: Cleans up, archives logs, and sends notifications

## Security Considerations

- Environment variables are stored securely as Jenkins credentials
- The .env file is automatically removed after pipeline execution
- Docker registry credentials are securely managed by Jenkins
- Different credentials are used for different environments
- Sensitive output is not logged

## Troubleshooting

If the pipeline fails:

1. Check the Jenkins console output for errors
2. Verify credentials are correctly set up
3. Ensure the Docker daemon is running on the Jenkins agent
4. Check Slack for notification details on the failure 