# syntax=docker/dockerfile:1
# One Alpine image: Hugo builds the site, Caddy serves it, Comentario provides
# comments under /comentario (matching layouts/partials/comments.html).
ARG ALPINE_VERSION=3.22
ARG HUGO_VERSION=0.169.0
ARG COMENTARIO_VERSION=3.19.0
ARG PAPERMOD_COMMIT=118119693d8b5ac211b939775678310973bcb232


FROM alpine:${ALPINE_VERSION} AS site
RUN apk add --no-cache ca-certificates curl gcompat git libstdc++
# Alpine's hugo package lags behind what this PaperMod commit requires (>=
# 0.158 for .Language.Direction), so take the released binary; it is linked
# against glibc, hence gcompat.
ARG HUGO_VERSION
ARG TARGETARCH
RUN set -eu; \
    file="hugo_extended_${HUGO_VERSION}_linux-${TARGETARCH}.tar.gz"; \
    base="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}"; \
    curl -fsSL --retry 3 -o /tmp/hugo.tgz "$base/$file"; \
    curl -fsSL --retry 3 -o /tmp/hugo.sums "$base/hugo_${HUGO_VERSION}_checksums.txt"; \
    expected=$(awk -v f="$file" '$2 == f { print $1 }' /tmp/hugo.sums); \
    [ "$expected" = "$(sha256sum /tmp/hugo.tgz | cut -d' ' -f1)" ] || { echo "hugo checksum mismatch" >&2; exit 1; }; \
    tar -xzf /tmp/hugo.tgz -C /usr/local/bin hugo; \
    rm /tmp/hugo.tgz /tmp/hugo.sums
WORKDIR /src
COPY . .
# Theme submodule is not checked out in the build context; pin the same commit.
ARG PAPERMOD_COMMIT
RUN rm -rf themes/PaperMod \
 && git init -q themes/PaperMod \
 && git -C themes/PaperMod remote add origin https://github.com/adityatelange/hugo-PaperMod.git \
 && git -C themes/PaperMod fetch -q --depth 1 origin "$PAPERMOD_COMMIT" \
 && git -C themes/PaperMod checkout -q FETCH_HEAD \
 && rm -rf themes/PaperMod/.git
RUN hugo --gc --minify --destination /srv


FROM alpine:${ALPINE_VERSION} AS runtime
ARG COMENTARIO_VERSION
RUN apk add --no-cache ca-certificates caddy curl tini
# Comentario ships a statically linked binary + frontend; checksums from the
# release's checksums.txt.
ARG TARGETARCH
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) sha=73af7c1f48057652318f2ffb3200b964f24fe5afc9ec24e8c40c2f0695787582 ;; \
      arm64) sha=a5f6bf08f00000f655adba97420ccdae4686e0ce665616ee43eb0c9b4a78e4ab ;; \
      *) echo "unsupported arch: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    url="https://gitlab.com/api/v4/projects/42486427/packages/generic/comentario/${COMENTARIO_VERSION}/comentario-static_${COMENTARIO_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    curl -fsSL --retry 3 -o /tmp/comentario.tgz "$url"; \
    echo "${sha}  /tmp/comentario.tgz" | sha256sum -c -; \
    mkdir -p /opt/comentario; \
    tar -xzf /tmp/comentario.tgz -C /opt/comentario --strip-components=1; \
    rm /tmp/comentario.tgz

COPY --from=site /srv /srv
COPY Caddyfile /etc/caddy/Caddyfile
COPY docker/secrets.yaml.tmpl /etc/comentario/secrets.yaml.tmpl
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV STATIC_PATH=/opt/comentario/frontend \
    HOST=0.0.0.0 \
    PORT=8080 \
    XDG_DATA_HOME=/data \
    XDG_CONFIG_HOME=/data/config
EXPOSE 80
VOLUME ["/data"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
