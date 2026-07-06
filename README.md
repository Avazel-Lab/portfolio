# portfolio

The public site at **https://avazel.co.uk** — a static page served by nginx, built and
deployed automatically.

## How it ships

```
push to main → Gitea Actions builds the image → pushes to Harbor
             → Kubernetes pulls harbor.avazel.co.uk/homelab/portfolio:latest
```

The Deployment lives in `homelab-gitops` (`clusters/homelab/services/portfolio/`); this
repo owns only the content and the image.

## Editing the site

Edit `index.html` (the whole site is that one file) and push to `main` — or use Gitea's
web editor. The pipeline rebuilds and pushes the image; the running pod picks it up on
its next restart:

```bash
kubectl -n portfolio rollout restart deploy portfolio
```

## CI secrets

`Settings → Actions → Secrets`: `HARBOR_USER` / `HARBOR_TOKEN` — the `robot$portfolio-ci`
Harbor robot account (push+pull on the `homelab` project).
