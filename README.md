# PHPNomad WordPress Plugin Recipes

Scaffolding recipes that speak WordPress vocabulary and produce idiomatic PHPNomad structure. Consumed by `phpnomad/cli` via composer-based kit discovery.

## Installation

Usually you don't install this directly. It's a transitive dependency of [`phpnomad/wp-plugin-starter`](https://github.com/phpnomad/wp-plugin-starter):

```bash
composer create-project phpnomad/wp-plugin-starter my-plugin
```

The starter depends on this kit, so the recipes are immediately available inside the new project.

To install into an existing project:

```bash
composer require phpnomad/wp-plugin-recipes --dev
```

## Recipes provided

### Bootstrap

| Recipe | Purpose |
|---|---|
| `phpnomad/wp-plugin` | Bootstrap a brand-new WordPress plugin: entry file, Application class, root initializer, composer.json, tests, configuration |

### Storage trilogies

Each WordPress storage primitive comes in three variants — register only, handler-against-existing-datastore, and full-stack composite — mirroring the elevator pattern from `phpnomad/database-datastore` in core-recipes.

| Just register | Handler against existing datastore | Full-stack composite |
|---|---|---|
| `phpnomad/cpt` | `phpnomad/cpt-handler` | `phpnomad/cpt-datastore` |
| `phpnomad/taxonomy` | `phpnomad/taxonomy-handler` | `phpnomad/taxonomy-datastore` |
| `phpnomad/option` | `phpnomad/option-provider` | `phpnomad/setting` |
| `phpnomad/meta` | `phpnomad/meta-provider` | `phpnomad/attribute` |

CPT and taxonomy recipes implement all four datastore handler interfaces (`Datastore`, `DatastoreHasPrimaryKey`, `DatastoreHasWhere`, `DatastoreHasCounts`) using WordPress core APIs. Option and meta recipes are simpler — the "handler" tier is a typed accessor service rather than a full CRUD adapter.

### Auth and admin surfaces

| Recipe | Purpose |
|---|---|
| `phpnomad/role` | Add a WordPress user role on Ready (idempotent) |
| `phpnomad/admin-page` | Top-level wp-admin menu page with capability gating |
| `phpnomad/admin-notice` | Banner-style admin notice with conditional render |
| `phpnomad/admin-bar-item` | Quick-access node in the WordPress admin bar |
| `phpnomad/shortcode` | Register a `[shortcode]` tag with a render handler |

### Scheduling and assets

| Recipe | Purpose |
|---|---|
| `phpnomad/cron-job` | Schedule and handle a recurring WP-Cron job |
| `phpnomad/scripts-bundle` | Enqueue a JS bundle (front-end and/or admin), reads `.asset.php` for deps |
| `phpnomad/styles-bundle` | Enqueue a CSS bundle (front-end and/or admin) |

All registration recipes scaffold a class implementing `CanHandle` that responds to PHPNomad's `Ready` event, mapped into the initializer's `getListeners()`. Composites pass vars through to child recipes.

Run `vendor/bin/phpnomad recipes:list --all=1` inside a project to see the full list with summaries.

## Bootstrap workflow

```bash
composer create-project phpnomad/wp-plugin-starter my-plugin
cd my-plugin
vendor/bin/phpnomad make --from=phpnomad/wp-plugin '{
  "pluginName": "My Plugin",
  "description": "What my plugin does.",
  "vendor": "acme",
  "package": "my-plugin",
  "namespace": "AcmePlugin",
  "textDomain": "my-plugin",
  "authorName": "Your Name",
  "authorEmail": "you@example.com",
  "authorUrl": ""
}'
```

After the bootstrap recipe runs, you have a working PHPNomad WordPress plugin. From there, use the rest of PHPNomad's recipes to add functionality.

## Writing your own kit

This kit is also a reference implementation for writing your own. The pattern:

1. Create a composer package
2. In its `composer.json`, declare `extra.phpnomad.recipes` and `extra.phpnomad.templates` pointing to directories in your package
3. Drop JSON recipe files in the recipes directory and `.tpl` template files in the templates directory
4. Reference recipes from other kits (this one references `phpnomad/core-recipes`) via composer require, not via custom recipe-level declarations

Recipes inside your kit are referenced as `<your-vendor>/<recipe-name>`.

## License

MIT
