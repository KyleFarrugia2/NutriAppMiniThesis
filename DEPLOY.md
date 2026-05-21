# Deploy Nutri Work on the web (for testers)

## Recommended: Vercel

Best for a **clean URL** (e.g. `nutri-work.vercel.app`) and easy sharing with testers.

### One-time Vercel setup

1. Push this repo to GitHub (`KyleFarrugia2/Minithesis`).
2. Go to [vercel.com](https://vercel.com) → **Add New Project** → import **Minithesis**.
3. **Important — Root Directory:** click *Edit* and set to **`nutri_work_app`** (not the repo root).
4. Framework Preset: **Other** (Vercel reads `vercel.json` automatically).
5. Environment variables (optional, **Settings → Environment Variables**):

   | Name | Example |
   |------|---------|
   | `PUBLIC_WEB_URL` | `https://nutri-work.vercel.app` (your production URL after first deploy) |
   | `FEEDBACK_FORM_URL` | `https://forms.gle/xxxx` |
   | `SUPPORT_EMAIL` | `kyle.farrugia.j94928@mcast.edu.mt` |

6. Click **Deploy**. First build installs Flutter (~5–10 min); later builds are faster.
7. After deploy, copy your production URL and set `PUBLIC_WEB_URL` to that value, then **Redeploy** so “Copy link” in the app is correct.

### Deploy from your PC (CLI)

```bash
npm i -g vercel
cd nutri_work_app
vercel login
vercel --prod
```

Follow prompts; ensure the project root is `nutri_work_app`.

### Files used by Vercel

- `vercel.json` — build output `build/web`, runs `scripts/vercel-build.sh`
- `scripts/vercel-build.sh` — installs Flutter stable and runs `flutter build web`

---

## Tester feedback & questions

### In the app

**Profile → Feedback & questions**

- **Email question** — opens the default mail app with your message to `kyle.farrugia.j94928@mcast.edu.mt`.
- **Open feedback form** — opens a Google Form (once configured below).
- **Copy link** — share the public test URL (web only).

### Google Form (recommended for many testers)

1. Go to [Google Forms](https://forms.google.com) and create a form, e.g. “Nutri Work — tester feedback”.
2. Suggested fields: name (optional), ease of use (1–5), what worked well, what was confusing, would you use this again (yes/no).
3. Copy the **share link** (e.g. `https://forms.gle/xxxxx`).
4. Either edit `lib/config/app_config.dart` (`feedbackFormUrl` default) or set `FEEDBACK_FORM_URL` in Vercel environment variables, then redeploy.

---

## Web limitations

| Feature | Web |
|--------|-----|
| Onboarding, meals (catalog + manual), workouts, dashboard | Works |
| Data storage | Browser local storage |
| USDA live search | Often blocked by browser CORS; use built-in food catalog |
| Install as app | “Add to Home Screen” on mobile browsers |

---

## Local web preview

```bash
cd nutri_work_app
flutter pub get
flutter run -d chrome
```
