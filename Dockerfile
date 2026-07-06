# Static site on nginx. The Deployment expects the container to listen on :80
# (clusters/homelab/services/portfolio/deployment.yaml in homelab-gitops).
FROM nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
