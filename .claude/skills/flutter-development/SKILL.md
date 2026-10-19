
---
name: flutter-development
description: Implement and improve Flutter and Dart applications using the existing project architecture, idiomatic Flutter patterns, accessible UI, and appropriate tests. Use when creating screens, widgets, state management, navigation, camera features, or Flutter services.
---

# Flutter Development

## Before coding
- Inspect the project structure and read its CLAUDE.md.
- Check pubspec.yaml and the existing Flutter and Dart versions.
- Identify the current state management, navigation, and UI conventions.
- Reuse existing widgets, services, and dependencies.

## Implementation
- Follow idiomatic Dart and Flutter conventions.
- Prefer small, cohesive widgets and clear responsibilities.
- Keep business logic out of UI widgets when practical.
- Reuse the project's existing state management approach.
- Avoid unnecessary packages, abstractions, and duplicate code.
- Handle loading, success, empty, and error states.
- Dispose controllers, streams, and other resources correctly.
- Respect accessibility, responsive layouts, and readable contrast.
- Do not rewrite unrelated files.

## Camera and device features
- Handle runtime permissions and denied-permission states.
- Release camera resources when the feature is no longer active.
- Avoid blocking the UI during expensive processing.
- Explain platform-specific configuration when required.
- Never claim that a recognition model works without testing it.

## Verification
- Run dart format on changed Dart files when appropriate.
- Run flutter analyze.
- Run focused tests and relevant existing tests.
- Report commands executed and actual results.
- Do not claim that checks passed if they were not run.
