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

## Résumé des endpoints

| Module | Prefix | Endpoints | Statut |
|--------|--------|-----------|--------|
| Authentification | `/auth/` | signup, login, profile, forgot-password, reset-password, change-password | ✅ Actif |
| Inventaire | `/inventory/` | categories, products, stock | ✅ Actif |
| Laboratoire | `/laboratory/` | - | 🚧 En développement |
| Commandes | `/orders/` | - | 🚧 En développement |
| Fournisseurs | `/suppliers/` | - | 🚧 En développement |
| Notifications | `/notifications/` | - | 🚧 En développement |
| IA | `/ai/` | - | 🚧 En développement |

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

## Inventaire (Inventory)

Les endpoints d'inventaire gèrent les catégories, produits et stocks.

### `GET /inventory/categories/`

Liste toutes les catégories de produits.

Réponse `200 OK` :

```json
[
  {
    "id": 1,
    "name": "Électronique",
    "description": "Composants électroniques",
    "created_at": "2026-08-16T10:30:00Z",
    "updated_at": "2026-08-16T10:30:00Z"
  }
]
```

### `POST /inventory/categories/`

Crée une nouvelle catégorie. Authentification requise.

Corps JSON :

```json
{
  "name": "Chimie",
  "description": "Produits chimiques"
}
```

Réponse `201 Created` : la catégorie créée.

### `GET /inventory/categories/<int:pk>/`

Récupère les détails d'une catégorie.

### `PUT/PATCH /inventory/categories/<int:pk>/`

Met à jour une catégorie. Authentification requise.

### `DELETE /inventory/categories/<int:pk>/`

Supprime une catégorie. Authentification requise.

### `GET /inventory/products/`

Liste tous les produits.

Réponse `200 OK` :

```json
[
  {
    "id": 1,
    "name": "Microcontrôleur Arduino",
    "sku": "ARD-001",
    "description": "Microcontrôleur Arduino Uno",
    "price": "25.50",
    "is_active": true,
    "category": {
      "id": 1,
      "name": "Électronique",
      "description": "Composants électroniques",
      "created_at": "2026-08-16T10:30:00Z",
      "updated_at": "2026-08-16T10:30:00Z"
    },
    "created_at": "2026-08-16T11:00:00Z",
    "updated_at": "2026-08-16T11:00:00Z"
  }
]
```

### `POST /inventory/products/`

Crée un nouveau produit. Authentification requise.

Corps JSON :

```json
{
  "name": "Capteur de température",
  "sku": "TEMP-001",
  "description": "Capteur numérique DS18B20",
  "price": "5.00",
  "is_active": true,
  "category_id": 1
}
```

Réponse `201 Created` : le produit créé.

### `GET /inventory/products/<int:pk>/`

Récupère les détails d'un produit.

### `PUT/PATCH /inventory/products/<int:pk>/`

Met à jour un produit. Authentification requise.

### `DELETE /inventory/products/<int:pk>/`

Supprime un produit. Authentification requise.

### `GET /inventory/stock/`

Liste tous les articles en stock.

Réponse `200 OK` :

```json
[
  {
    "id": 1,
    "product": {
      "id": 1,
      "name": "Microcontrôleur Arduino",
      "sku": "ARD-001",
      "description": "Microcontrôleur Arduino Uno",
      "price": "25.50",
      "is_active": true,
      "category": {...},
      "created_at": "2026-08-16T11:00:00Z",
      "updated_at": "2026-08-16T11:00:00Z"
    },
    "quantity": 50,
    "location": "Étagère A1",
    "last_updated": "2026-08-16T12:00:00Z"
  }
]
```

### `POST /inventory/stock/`

Crée un nouvel article en stock. Authentification requise.

Corps JSON :

```json
{
  "product_id": 1,
  "quantity": 100,
  "location": "Étagère A1"
}
```

Réponse `201 Created` : l'article créé.

### `GET /inventory/stock/<int:pk>/`

Récupère les détails d'un article en stock.

### `PUT/PATCH /inventory/stock/<int:pk>/`

Met à jour un article en stock. Authentification requise.

### `DELETE /inventory/stock/<int:pk>/`

Supprime un article en stock. Authentification requise.

## Autres applications

Les applications suivantes sont en développement et n'ont pas encore d'endpoints
implémentés :

- **Laboratory** (`/laboratory/`) : Gestion des essais et expériences
- **Orders** (`/orders/`) : Gestion des commandes
- **Suppliers** (`/suppliers/`) : Gestion des fournisseurs
- **Notifications** (`/notifications/`) : Notifications et alertes
- **AI** (`/ai/`) : Services d'intelligence artificielle


## Permissions

- `IsAuthenticatedOrReadOnly` : Les utilisateurs authentifiés peuvent modifier
  les données, les utilisateurs anonymes ne peuvent que lire.
- Les endpoints de modification (POST, PUT, PATCH, DELETE) nécessitent une
  authentification valide.

## Documentation interactive

- Schéma OpenAPI : `GET /openapi/`
- Interface Swagger : `GET /docs/`

Les tokens sont des JWT fournis par Django REST Framework Simple JWT. Le token
d'accès expire après 60 minutes et le token de rafraîchissement après 1 jour.
