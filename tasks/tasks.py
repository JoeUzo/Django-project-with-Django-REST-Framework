from celery import shared_task
import time, logging

logger = logging.getLogger(__name__)

@shared_task
def process_message(email, message):
    time.sleep(5)  # simulate work
    result = f"Done for {email}: {message}"
    logger.info(result)
    return result
