# Kubernetes Deployment for Microservice Application

This directory contains Kubernetes manifests to deploy the microservice application.

## Files
- `postgres-pvc.yaml`: Persistent Volume Claim for PostgreSQL
- `postgres-deployment.yaml`: PostgreSQL deployment and service
- `redis-deployment.yaml`: Redis deployment and service
- `web-deployment.yaml`: Web application deployment with NodePort service
- `worker-deployment.yaml`: Celery worker deployment
- `secrets.yaml`: Secret templates for application

## Deployment Instructions

1. First, create the PVC and secrets:
   ```
   kubectl apply -f postgres-pvc.yaml
   kubectl apply -f secrets.yaml
   ```

2. Update the `secrets.yaml` file with your actual credentials before applying.

3. Deploy the database and Redis:
   ```
   kubectl apply -f postgres-deployment.yaml
   kubectl apply -f redis-deployment.yaml
   ```

4. Deploy the web application and worker:
   ```
   kubectl apply -f web-deployment.yaml
   kubectl apply -f worker-deployment.yaml
   ```

5. Access the web application:
   ```
   # The web service is available on any node at port 30080
   http://<node-ip>:30080
   ```

## Notes

- The web service is exposed as a NodePort on port 30080
- PostgreSQL data is persisted using a PVC
- Ensure your Kubernetes cluster has a storage class that supports ReadWriteOnce access mode
- You may need to adjust resource requests and limits based on your environment 