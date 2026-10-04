# Pokédex

## Overview

A Flutter Pokédex powered by PokéAPI. Browse a paginated catalog, search the
loaded Pokémon, inspect type and stat details, and keep a favorites collection
that stays synchronized between the catalog, detail page, and Favorites tab.

## Screenshots

Screenshots can be added here after running the app on a device or emulator.

## How to run

Requirements: Flutter 3.47.6 (or compatible stable), Dart 3.13.5, and a working
network connection for Pokémon data and artwork.

```sh
cd pokedex_app
flutter pub get
flutter run
```

Pokémon data comes from the public PokéAPI. Favorites are stored on-device and
remain available when the API is offline.

## Architecture & folder structure

The code is organized feature-first with a small layered data boundary:

```text
lib/
  main.dart
  app.dart
  core/           # API constants, palette, theme, formatters and shared states
  data/
    models/       # Immutable API and favorite models
    datasources/  # Dio API client and SharedPreferences persistence
    repositories/# Provider-facing data access boundary
  providers/      # Shared service wiring
  features/
    home/         # IndexedStack and bottom navigation
    pokemon_list/ # Async list, pagination, search and cards
    pokemon_detail/
    favorites/    # Single source of truth for all favorite controls
```

UI widgets depend on Riverpod feature providers, which depend on repositories;
only the data source knows about Dio or SharedPreferences.

## State management choice

Riverpod 3 `Notifier` and `AsyncNotifier` make state ownership explicit and
testable without generated code. `AsyncNotifier` models initial and paginated
network states, while `Notifier` owns synchronous favorite and search state.
This avoids scattering business state through `setState`, and provides safer
dependency overrides and fine-grained subscriptions than a manually scoped
`Provider` tree. Bloc would add event/state ceremony for this small app, while
GetX couples state, routing, and service lookup more tightly than needed.

## Local storage choice

`shared_preferences` stores a small JSON list containing only each favorite's
ID, name, and artwork URL. It is a straightforward fit for a tiny key-value
collection and loads before the first frame. Hive, sqflite, and Isar are better
suited to larger structured datasets, queries, migrations, or substantial
offline databases, none of which this favorites set needs.

## Why Dio

Dio provides request timeouts, typed response handling, configurable base
options, and a single point for translating transport failures into
user-friendly `AppException` messages. This keeps HTTP details out of screens
and repositories.

## How real-time favorites sync works

There is exactly one favorites map in `FavoritesNotifier`. The map is updated
optimistically, then serialized to SharedPreferences; a failed save restores
the prior state and is surfaced to the user. List cards and the detail header
subscribe to only their own favorite membership with `select`, while the
Favorites tab derives its visible contents from that same map.

```text
             toggle (optimistic)
 UI heart ─────────────────────────> FavoritesNotifier (Map<int, Favorite>)
    ▲                                         │                │
    │                                         │ select(id)    └── JSON save
    ├──── List card                            ├── Detail header
    └──── Favorites grid <─────────────────────┘
```

Persisted favorites are loaded before `ProviderScope` starts, avoiding a
loading flicker on launch.

## Assumptions I made

- No Figma layout screenshots were supplied; the app uses a clean, responsive
  Material 3 Pokédex style with type-colored details.
- Search intentionally filters only pages already loaded from PokéAPI.
- Favorites are device-local and do not synchronize across accounts or devices.
- A failed favorite write rolls back the optimistic change and displays an
  error rather than reporting a false success.

## Known limitations

- Search does not query the full PokéAPI catalog.
- Pokémon details and uncached images require network access.
- There is no account, cross-device sync, or separate species/evolution data.
- Data pagination loads on scroll; it does not prefetch the following page.

## What I would improve with more time

- Add offline caching for Pokémon detail responses and artwork.
- Add unit, repository, widget, and integration tests for pagination and favorite
  synchronization.
- Polish Hero transitions and handle images with per-type transitions.
- Prefetch the next page and add resilient retry/backoff for transient errors.
- Add tablet layouts and localization.
