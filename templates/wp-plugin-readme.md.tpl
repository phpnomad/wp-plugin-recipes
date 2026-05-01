# {{pluginName}}

{{description}}

## Requirements

- PHP 8.2 or higher
- WordPress 6.0 or higher

## Installation

Install via Composer:

```bash
composer install
```

Then activate the plugin in WordPress.

## Development

This plugin is built on [PHPNomad](https://github.com/phpnomad/core) and uses its CLI for scaffolding new functionality.

```bash
# Add a datastore
vendor/bin/phpnomad make --from=phpnomad/datastore '{"name":"Order","initializer":"{{namespace}}\\AppInit"}'

# List available recipes
vendor/bin/phpnomad recipes:list

# See the full project shape
vendor/bin/phpnomad index
```

## License

GPL-2.0-or-later
