# SmartLab API

## Documentation des endpoints

Base URL locale : `http://<host>:8000`

Les endpoints d'authentification sont préfixés par `/auth/`. Les réponses
d'erreur utilisent généralement cette forme :

```json
{
  "success": false,
  "error": "Message d'erreur"
}
```

Les erreurs de validation peuvent utiliser `errors` à la place de `error`.

## Authentification

### `POST /auth/signup/`

Crée un compte utilisateur.

Corps JSON :

```json
{
  "username": "jdoe",
  "email": "jdoe@example.com",
  "password": "secret123"
}
```

Réponse `201 Created` :

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

Erreurs : `400` si un champ est manquant, `409` si l'adresse email existe déjà.

### `POST /auth/login/`

Authentifie un utilisateur avec son email et son mot de passe.

Corps JSON :

```json
{
  "email": "jdoe@example.com",
  "password": "secret123"
}
```

Réponse `200 OK` :

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

### `POST /auth/forgot-password/`

Demande l'envoi d'un email de réinitialisation. Cet endpoint est accessible
sans authentification.

Corps JSON :

```json
{
  "email": "jdoe@example.com"
}
```

Réponse `200 OK` :

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

Erreurs : `400` si l'email est invalide, `500` si l'email ne peut pas être envoyé.

### `POST /auth/reset-password/`

Réinitialise le mot de passe avec le token reçu par email. Cet endpoint est
accessible sans authentification.

Corps JSON :

```json
{
  "token": "<uuid-token>",
  "new_password": "newpass123",
  "confirm_password": "newpass123"
}
```

Réponse `200 OK` :

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

Erreurs : `400` si le token ou les mots de passe sont invalides, `500` en cas
d'erreur serveur.

### `GET /auth/reset-password/validate/<uuid:token>/`

Vérifie qu'un token de réinitialisation est valide et non expiré. Cet endpoint
est accessible sans authentification.

Réponse `200 OK` :

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

Réponse `400 Bad Request` si le token est invalide ou expiré.

### `POST /auth/change-password/`

Change le mot de passe d'un utilisateur authentifié.

En-tête requis :

```text
Authorization: Bearer <jwt-access-token>
```

Corps JSON :

```json
{
  "old_password": "oldpass",
  "new_password": "newpass123",
  "confirm_password": "newpass123"
}
```

Réponse `200 OK` :

```json
{
  "success": true,
  "message": "Votre mot de passe a été modifié avec succès."
}
```

Erreurs : `401` si l'utilisateur n'est pas authentifié, `400` si l'ancien mot
de passe ou le nouveau mot de passe est invalide.

### `GET /auth/profile/`

Retourne le profil de l'utilisateur authentifié.

En-tête requis : `Authorization: Bearer <jwt-access-token>`.

Réponse `200 OK` :

```json
{
  "id": 1,
  "email": "jdoe@example.com",
  "first_name": "",
  "last_name": "",
  "role": "tech"
}
```

### `PUT/PATCH /auth/profile/`

Met à jour le profil de l'utilisateur authentifié. Les champs disponibles sont
`email`, `first_name`, `last_name` et `role`.

En-tête requis : `Authorization: Bearer <jwt-access-token>`.

Réponse `200 OK` : le profil mis à jour, avec la même structure que la réponse
de lecture ci-dessus.

## Documentation interactive

- Schéma OpenAPI : `GET /openapi/`
- Interface Swagger : `GET /docs/`

Les tokens sont des JWT fournis par Django REST Framework Simple JWT. Le token
d'accès expire après 60 minutes et le token de rafraîchissement après 1 jour.
