# Datasets for experimentation (Milestone 02)

This repository does **not** bundle large public corpora. Download sources locally for offline model work, and keep only derived metrics or small samples in version control if your institution allows it.

## Food image classification (meal logging support)

| Dataset | Access | Scale | Typical use here |
|--------|--------|-------|------------------|
| **Food-101** | [Food-101 (EPFL)](https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/) | ~101k images, 101 classes | CNN baseline (top-1 / top-5), mobile-friendly shortlist UX |
| **UECFOOD-256** (and related UEC sets) | [UEC FOOD100/256](http://foodcam.mobi/dataset100.html) | Tens of thousands of images; some variants include boxes | Harder scenes, localization beyond single-plate photos |

**Suggested layout on disk (gitignored):** `datasets/vendor/food-101/` with `images/` and `meta/` as provided by the publisher.

## Sequential workout / activity logs

| Resource | Access | Notes |
|----------|--------|-------|
| **FitRec** and derivatives | See original FitRec publication and mirrors used by your recommender tutorial | Tabular logs: user, activity, timestamps, duration, performance fields—suitable for recall@k, NDCG@k |
| **Ni et al. (2019)** setting | Use whichever public splits your tutorial specifies | Compares sequence models vs simpler baselines |

## Nutrition and health (tabular / survey)

| Dataset | Access | Notes |
|---------|--------|-------|
| **NHANES** | [CDC NHANES](https://www.cdc.gov/nchs/nhanes/) | Public survey modules for dietary recall and health indicators; subgroup analysis, not required for the Flutter prototype shell |

## Private / informal logs (this app)

Optional exports from the app (meal entries, workouts, profile snapshots) are **private** and **small-N**. Treat any tallies as exploratory only; do not present them as population-level evidence.

---

**Ethics:** If you later recruit participants beyond informal self-testing, follow your faculty’s ethics process before collecting identifiable data.
