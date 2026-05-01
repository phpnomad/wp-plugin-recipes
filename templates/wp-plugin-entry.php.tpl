<?php
/*
 * Plugin Name: {{pluginName}}
 * Description: {{description}}
 * Author: {{authorName}}
 * Author URI: {{authorUrl}}
 * Version: 0.1.0
 * Requires PHP: 8.2
 * Text Domain: {{textDomain}}
 */

use {{namespace}}\Application;

if (!defined('ABSPATH')) {
    exit;
}

$autoload = plugin_dir_path(__FILE__) . 'vendor/autoload.php';

if (file_exists($autoload)) {
    require_once $autoload;
}

register_activation_hook(__FILE__, function () {
    (new Application(__FILE__))->install();
});

(new Application(__FILE__))->init();
