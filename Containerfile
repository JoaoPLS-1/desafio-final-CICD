FROM docker.io/library/nginx:stable-alpine
ARG VCS_REF=unknown
LABEL org.opencontainers.image.title="Desafio final CI/CD" \
      org.opencontainers.image.source="https://github.com/JoaoPLS-1/desafio-final-CICD" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.revision="${VCS_REF}"
COPY index.html styles.css /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1