from rest_framework import serializers
from .models import Task


class ProcessSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['email', 'message']
        # fields = "__all__"