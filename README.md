# portfolio

The public site at **https://avazel.co.uk** — a static page served by nginx, built and
deployed automatically.

## Source of truth & release flow

This GitHub repo is the **editable source of truth**. You never edit in Gitea — Gitea holds a
read-only pull-mirror of `main` and does the release build.

```
edit on a branch → open PR
   └─ GitHub Actions (.github/workflows/ci.yaml) builds + sanity-checks — REQUIRED to merge
merge to main
   └─ Gitea pull-mirrors main (every ~10 min)
        └─ scheduled Gitea Actions build (.gitea/workflows/build.yaml) → pushes image to Harbor
             └─ Kubernetes pulls harbor.avazel.co.uk/homelab/portfolio:latest
```

Why two workflows: GitHub's hosted runners can't reach the in-cluster Harbor, and a Gitea
pull-mirror sync doesn't fire Gitea Actions — so GitHub *validates* on PR (gating merge) and
Gitea *builds/pushes* on a schedule. The image is tagged with the commit SHA; the scheduled
job skips the build when that SHA is already in Harbor, so it's a cheap no-op between changes.

The Deployment lives in `homelab-gitops` (`clusters/homelab/services/portfolio/`); this repo
owns only the content and the image.

## Editing the site

The whole site is `index.html`. Edit it on a branch, open a PR, get the `ci` check green, and
merge. Within ~10–15 min the mirror syncs and the scheduled build ships the new image. To pick
it up immediately on the running pod:

```bash
kubectl -n portfolio rollout restart deploy portfolio
```

To ship without waiting for the schedule, trigger the Gitea build manually (Gitea → the
mirrored `portfolio` repo → Actions → **build** → Run workflow), or wait for the next tick.

## CI secrets

The GitHub `ci` workflow needs no secrets. The **Gitea** mirror repo needs
`Settings → Actions → Secrets`: `HARBOR_USER` / `HARBOR_TOKEN` — the `robot$homelab+portfolio-ci`
Harbor robot account (push+pull on the `homelab` project).
