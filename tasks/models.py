from django.db import models

# Create your models here.
class Task(models.Model):
    email = models.EmailField(max_length=100)
    message = models.TextField()

    def __str__(self):
        return self.task_title