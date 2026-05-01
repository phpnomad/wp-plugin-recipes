{
    "name": "{{vendor}}/{{package}}",
    "description": "{{description}}",
    "type": "wordpress-plugin",
    "license": "GPL-2.0-or-later",
    "authors": [
        {
            "name": "{{authorName}}",
            "email": "{{authorEmail}}"
        }
    ],
    "minimum-stability": "dev",
    "prefer-stable": true,
    "require": {
        "php": "^8.2",
        "phpnomad/core": "^1.0",
        "phpnomad/wordpress-integration": "^4.0"
    },
    "require-dev": {
        "phpnomad/cli": "^1.0",
        "phpnomad/core-recipes": "^1.0",
        "phpnomad/wp-plugin-recipes": "^1.0",
        "phpunit/phpunit": "^10.0 || ^11.0"
    },
    "autoload": {
        "psr-4": {
            "{{namespace}}\\": "lib/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "{{namespace}}\\Tests\\": "tests/"
        }
    },
    "config": {
        "allow-plugins": {
            "composer/installers": true
        },
        "sort-packages": true
    }
}
