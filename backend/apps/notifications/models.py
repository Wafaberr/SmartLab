from django.conf import settings
from django.db import models


class Notification(models.Model):
	KIND_CHOICES = [
		('info', 'Info'),
		('warning', 'Warning'),
		('success', 'Success'),
		('error', 'Error'),
	]

	recipient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
	title = models.CharField(max_length=180)
	message = models.TextField()
	kind = models.CharField(max_length=20, choices=KIND_CHOICES, default='info')
	is_read = models.BooleanField(default=False)
	created_at = models.DateTimeField(auto_now_add=True)

	class Meta:
		ordering = ['-created_at']
