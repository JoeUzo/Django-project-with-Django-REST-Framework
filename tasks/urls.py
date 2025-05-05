from django.urls import path
from .views import ProcessView, StatusView

urlpatterns = [
    path('process/', ProcessView.as_view()),
    path('status/<task_id>/', StatusView.as_view()),
]
