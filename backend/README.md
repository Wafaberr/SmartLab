# SmartLab

## API Documentation

### Authentication

#### POST /auth/signup/
Creates a new user account.

Request body:
```json
{
  "username": "jdoe",
  "email": "jdoe@example.com",
  "password": "secret123"
}
```

Success response (201 Created):
```json
{
  "user": {
    "id": 1,
    "email": "jdoe@example.com",
    "first_name": "",
    "last_name": "",
    "role": "tech"
  },
  "access": "<jwt-access-token>",
  "refresh": "<jwt-refresh-token>"
}
```

#### POST /auth/login/
Authenticates a user with email and password.

Request body:
```json
{
  "email": "jdoe@example.com",
  "password": "secret123"
}
```

Success response (200 OK):
```json
{
  "refresh": "<jwt-refresh-token>",
  "access": "<jwt-access-token>",
  "user": {
    "id": 1,
    "email": "jdoe@example.com",
    "first_name": "",
    "last_name": "",
    "role": "tech"
  }
}
```

### Password reset

#### POST /auth/password-reset/request/
Demande l'envoi d'un email de réinitialisation de mot de passe.

Request body:
```json
{
  "email": "jdoe@example.com"
}
```

Success response (200 OK):
```json
{
  "success": true,
  "message": "Un email de réinitialisation a été envoyé à votre adresse.",
  "data": {
    "email": "jdoe@example.com",
    "token_sent": true
  }
}
```

#### POST /auth/password-reset/confirm/
Confirme la réinitialisation et met à jour le mot de passe avec le token reçu par email.

Request body:
```json
{
  "token": "<uuid-token>",
  "new_password": "newpass123",
  "confirm_password": "newpass123"
}
```

Success response (200 OK):
```json
{
  "success": true,
  "message": "Votre mot de passe a été réinitialisé avec succès.",
  "data": {
    "access_token": "<jwt-access-token>",
    "refresh_token": "<jwt-refresh-token>",
    "user": {
      "id": 1,
      "email": "jdoe@example.com",
      "username": "jdoe"
    }
  }
}
```

#### GET /auth/password-reset/validate/<uuid:token>/
Valide qu'un token de réinitialisation est toujours utilisable.

Success response (200 OK):
```json
{
  "success": true,
  "message": "Token valide.",
  "data": {
    "valid": true,
    "user_email": "jdoe@example.com",
    "user_id": 1,
    "expires_at": "2026-08-10T12:34:56.789000Z"
  }
}
```

#### POST /auth/password-change/
Change le mot de passe pour un utilisateur déjà authentifié.

Headers:
- `Authorization: Bearer <token>`

Request body:
```json
{
  "old_password": "oldpass",
  "new_password": "newpass123",
  "confirm_password": "newpass123"
}
```

Success response (200 OK):
```json
{
  "success": true,
  "message": "Votre mot de passe a été modifié avec succès."
}
```

### Notes
- The authentication endpoints use JWT via Django REST Framework Simple JWT.
- The default user role is `tech` unless changed in the database.

