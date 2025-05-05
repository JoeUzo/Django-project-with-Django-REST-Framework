from django.shortcuts import render

# Create your views here.
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from celery.result import AsyncResult

from .serializers import ProcessSerializer
from .tasks import process_message

class ProcessView(APIView):
    def post(self, request):
        ser = ProcessSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        task = process_message.delay(
            ser.validated_data['email'],
            ser.validated_data['message']
        )
        return Response({'task_id': task.id},
                        status=status.HTTP_202_ACCEPTED)

class StatusView(APIView):
    def get(self, request, task_id):
        res = AsyncResult(task_id)
        return Response({
            'task_id': task_id,
            'status': res.status,
            'result': res.result if res.status == 'SUCCESS' else None
        })
