# SmartLab Flutter

Client Flutter de gestion de laboratoire et de stock.

## Démarrage

Depuis `smartlaboratory/` :

```powershell
flutter pub get
flutter run
```

L’API utilisée est configurée dans `lib/core/constants/endpoints.dart`.
Adaptez `Endpoints.baseUrl` à l’adresse IP de la machine qui lance Django.

## Fonctionnalités

- Authentification JWT avec reconnexion persistante et refresh automatique.
- Dashboard de stock.
- Liste, détail, ajout, modification et suppression de produits.
- Images produit stockées en binaire dans la base via multipart et data URL.
- Entrées/sorties de stock et historique des mouvements.
- Parcours `+` de session d’analyse : type, session, consommation réelle,
  validation, mise à jour automatique du stock et pertes.
- Profil, modification du profil et changement du mot de passe.
- Interface disponible en français et en anglais, avec préférence persistante.

## Changer la langue

Ouvrez `Plus`, puis `Langue`, et sélectionnez `Français` ou `English`. Le choix
est sauvegardé localement et restauré au prochain démarrage.

## Vérification

```powershell
flutter analyze
flutter test
```

## Structure

- `lib/core/` : réseau, endpoints, stockage local et navigation.
- `lib/features/auth/` : authentification et profil.
- `lib/features/products/` : produits, images, stock et mouvements.
- `lib/features/laboratory/` : sessions d’analyse.
- `lib/features/home/` : dashboard et navigation principale.
