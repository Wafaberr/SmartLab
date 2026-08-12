# SmartLab Agent Instructions

## Repository map

SmartLab is a two-part application:

- `smartlaboratory/` is the Flutter client. Start at `lib/main.dart`; shared infrastructure lives in `lib/core/`, and user-facing work is organized under `lib/features/`.
- `backend/` is the Django REST API. `backend/manage.py` is the command entry point, `backend/SmartLab/` contains project settings and URL routing, and domain modules live under `backend/apps/`.
- Treat the root `apps/` directory as incomplete/legacy unless a task explicitly refers to it. The runnable Django project is under `backend/`.

Read the existing API documentation before changing client/server contracts: [backend/README.md](backend/README.md). The Flutter README is [smartlaboratory/README.md](smartlaboratory/README.md).

## Common commands

Run Flutter commands from `smartlaboratory/`:

```text
flutter pub get
flutter analyze
flutter test
flutter run
```

Run Django commands from `backend/`:

```text
python manage.py migrate
python manage.py test
python manage.py runserver
```

No backend dependency manifest is currently present in the repository. Use the project’s existing Python environment and report missing packages rather than inventing setup files during unrelated tasks.

## Architecture and conventions

- Keep Flutter changes aligned with the existing feature layers: `data` contains remote data sources, models, and repository implementations; `domain` contains repository contracts; `presentation` contains Cubits, screens, and widgets.
- Reuse the shared Flutter services in `lib/core/`: `DioClient` for HTTP, `endpoints.dart` for API paths/base URL, `app_router.dart` for GoRouter navigation and auth redirects, and the shared-preferences service for local auth state.
- Use `flutter_bloc` for state management and preserve repository injection through Cubit constructors. Add routes through `AppRouter` rather than navigating around the central router.
- The Django API is split into apps such as `auth`, `inventory`, `laboratory`, `notifications`, `orders`, `supliers`, and `ai`. Keep models, views, serializers, URLs, migrations, and tests inside their owning app.
- Authentication endpoints are under `/auth/` and use JWT access/refresh tokens. Preserve the documented response envelope (`success` plus `error` or `errors` for failures) when extending auth behavior.
- Keep client endpoint constants and backend URL routes synchronized. For password reset changes, trace the full flow: backend token model/view/email utility, client data source/repository/Cubit, deep-link handling, and router route.

## Change and validation rules

- Inspect nearby implementations and tests before introducing a new abstraction or dependency. Keep edits scoped to the owning layer.
- Add or update focused tests for behavior changes. At minimum, run `flutter analyze` and relevant Flutter tests for client changes, and `python manage.py test` for backend changes.
- Do not edit `smartlaboratory/build/`, platform `flutter/` generated directories, or other generated artifacts unless the task specifically targets build tooling. Regenerate them with Flutter instead.
- Do not commit secrets. The development Django settings contain insecure development defaults; use environment-based settings for production work and do not copy those values into the client or documentation.
- Preserve existing naming and public APIs unless a task requires a migration. Verify both sides of any API contract change.
