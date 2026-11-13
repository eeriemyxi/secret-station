# Secret Station
This is my personal website. I mostly post blogs there.

It is powered by Hugo and PaperMod theme. It uses Comentario for comments. And
it uses ChatGPT-assisted Gruvbox Medium styling patches.

My blogs are human written.

## Actions
I tend to edit the `justfile` with useful commands so that I don't have to
remember my workflow. Additional notes would be on this README.

## Docker
Docker exists here so I don't have to do this by hand.

Hugo builds the site at image build time. Caddy serves it. The Comentario binary
serves comments under `/comentario`. Postgres is a sibling container.

```sh
cp .env.example .env
docker compose up -d --build
```

Site is at http://localhost:8080.

- The proxy keeps `/comentario/*` unstripped. `layouts/partials/comments.html`
  wants `<base>/comentario/comentario.js`, so the whole path must reach
  Comentario. `handle_path` breaks it.
- `BASE_URL` needs the `/comentario` prefix, for example
  `https://myxi.eu.cc/comentario`. Without it the embed script and the REST API
  return 404.
- `migrations/` runs once before the web container.
  `001_create_comentario.sql` creates the `comentario` database and records
  itself in `_migrations`. Comentario builds its own schema on first start.
- First visit: open `/comentario/` and sign up. The first user becomes
  superuser. Add the domain in the admin UI after that.
- The comments partial hardcodes `https://myxi.eu.cc/...`. A local stack on
  `localhost:8080` shows the widget only after you point that at the local URL.
- `just backup` tars the postgres cluster into `backups/`. Everything else
  rebuilds from the repo.
- `just __restore backups/<file>` loads a backup. It is hidden from `just --list`
  on purpose. It asks for confirmation, wipes the postgres volume, then starts
  the stack again. A pg_dumpall dump only loads into an empty cluster. The
  `role "postgres" already exists` error during import is expected.
- To reset to nothing, run `docker compose down -v && just up`. That drops every
  container and both volumes (`db`, `web-data`), then rebuilds a clean stack.
  The database comes back empty. The migration and Comentario's start-up rebuild
  the schema. Run `just backup` first if there is anything to keep.
