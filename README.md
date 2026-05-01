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

| Recipe | Purpose |
|---|---|
| `phpnomad/wp-plugin` | Bootstrap a brand-new WordPress plugin: entry file, Application class, root initializer, composer.json, tests, configuration |

More recipes will land here as the WordPress vocabulary kit grows: custom post types, taxonomies, options pages, REST endpoints, admin screens.

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
