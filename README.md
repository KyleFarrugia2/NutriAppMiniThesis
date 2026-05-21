# Nutri Work — personalized nutrition and workout (thesis prototype)

Flutter mobile application supporting **personalized calorie and macronutrient targets** and **recency-aware workout suggestions**, with local persistence. The codebase is structured so **food image ML** and **learned recommenders** can replace the current explainable rule layer without redesigning the UI shell.

## Milestone 02 deliverables (in this repo)

| Item | Location |
|------|-----------|
| Final prototype source | This repository (`lib/`, platform folders) |
| Dataset documentation (public sources; no large blobs in git) | `datasets/README.md` |
| IEEE-style conference paper (LaTeX → PDF) | `paper/nutri_work_ieee.tex`, `paper/references.bib`, compile via `paper/BUILD.txt` |
| Viva slides (LaTeX Beamer → PDF) | `viva/viva_presentation.tex`, compile via `viva/BUILD.txt` |

**Your tasks before submission:** replace placeholder author/affiliation in `paper/nutri_work_ieee.tex` and `viva/viva_presentation.tex`; compile PDFs; record a **≤2 minute** demo of the app for your viva (screen capture from emulator or device).

## Features (current build)

- **Food logging:** **Search foods** (USDA FoodData Central when you add a free API key under Profile, plus a built‑in list of common staples such as chicken breast, eggs, and oats). Pick an item, set **portion in grams**, and macros scale from the per‑100 g basis. **Custom meal** keeps full manual entry (name + calories + macros).
- Onboarding: profile (demographics, goal, activity, optional average steps).
- **Nutrition tab:** `SliverAppBar`, daily summary strip, **Add food** sheet (search vs custom), swipe-to-delete, source icons (manual vs catalog/USDA).
- Workout tab: validated log sheet (title + duration) with cancel; next-workout card shows **Adaptive** vs **Fixed** chip, rationale, and intensity; swipe-to-delete on history. Engine logic lives in `lib/services/personalization_engine.dart`.
- **Adaptive vs fixed:** Profile toggle or Edit profile → **Adaptive** uses your last 7 days of logs; **Fixed** uses a weekday-only rotation that **ignores logs** for a clear baseline when comparing behaviour in write-ups or demos.
- Dashboard: calorie progress (warns when over target), macro bars, explainable insights, collapsible **How your plan works**.

## Web demo for testers

Deploy on **[Vercel](DEPLOY.md)** (recommended) or [GitHub Pages](DEPLOY.md).

After deploy, share your URL (e.g. `https://your-project.vercel.app`). Testers use **Profile → Feedback & questions** to email you or open your Google Form.

## Run the app

Requires [Flutter](https://docs.flutter.dev/get-started/install) (SDK >=3.2).

```bash
cd "path/to/nutri_work_app"
flutter pub get
flutter run
```

Web locally: `flutter run -d chrome`

Optional: pass a USDA key at compile time (Profile → USDA can also save it on device):

```bash
flutter run --dart-define=USDA_API_KEY=your_key_here
```

## Project alignment (Milestone 01)

- **Keywords:** personalized nutrition; workout recommendation; mobile health; machine learning; food image recognition.
- **Evaluation:** informal comparison for adaptive vs. fixed behaviour; offline metrics (top-1/top-5, recall@k, NDCG@k) documented for when ML modules are trained on public data; limitations explicitly acknowledged.

## License / academic use

Use and adapt for your thesis submission per your institution’s rules. Third-party Flutter/SDK licenses apply to dependencies (see `pubspec.lock`).
