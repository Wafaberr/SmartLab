from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from django.core.validators import RegexValidator
import uuid

# Create your models here.  
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('the email field must be set')

        email = self.normalize_email(email)
        username = extra_fields.pop('username', None)
        if username:
            extra_fields['username'] = username
        else:
            extra_fields['username'] = email.split('@', 1)[0]
        extra_fields.setdefault('first_name', username or '')
        extra_fields.setdefault('last_name', '')
        extra_fields.setdefault('is_active', True)

        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'admin')
        extra_fields.setdefault('first_name', '')
        extra_fields.setdefault('last_name', '')

        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):  # Correction: La classe User doit être en dehors de UserManager
    ROLE_CHOICES = [('admin', 'Admin'), ('tech', 'Tech')]
    
    username = models.CharField(max_length=150, unique=True, blank=True, default='')
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=50, blank=True, default='')
    last_name = models.CharField(max_length=50, blank=True, default='')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='tech')
  
    image = models.ImageField(upload_to='profile_images/', null=True, blank=True)
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)  # Ajouté pour l'admin
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    objects = UserManager()
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []
    
    class Meta:
        db_table = 'users'
    
    def __str__(self):
        return self.email
    
    def get_full_name(self):
        return f"{self.first_name} {self.last_name}"
    
    def get_short_name(self):
        return self.first_name
    
    
class PasswordResetToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Password reset token for {self.user.email}"