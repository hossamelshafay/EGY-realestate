# EGY DEVELOPMENT project guidance

Follow `.agents/rules/egy-development.md` and relevant documentation. Preserve feature-first MVVM, Cubit, go_router, manual get_it and localization. Use approved assets and design tokens. Keep files under 400 lines. Do not modify the Python backend or Firebase configuration. Work within the approved phase and run relevant checks.

## Key Architecture Notes

- **Reference architecture:** [hossamelshafay/ConnectHub](https://github.com/hossamelshafay/ConnectHub) — Feature-First + MVVM + Cubit + Repository.
- **Naming convention:** EGY uses `presentation/pages/` (not `views/`) and `presentation/cubit/` (not `manager/cubit/`).
- **Splash** is a standalone feature at `lib/features/splash/` with no `data/` layer. It owns first-run routing via `SplashCubit` (checks `SharedPreferences`), not via a GoRouter `redirect`.
- **Onboarding** is a separate feature at `lib/features/onboarding/`. There is no `WelcomePage` — it was removed.
- **GoRouter `redirect`** is reserved for auth-aware route protection (Phase 4+). Simple first-run routing belongs in a Cubit.
- Do NOT place feature files at `lib/` root — all features live in `lib/features/<name>/`.
