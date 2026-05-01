<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Registers the {{taxonomy}} taxonomy when the Ready event fires.
 *
 * Edit the array passed to register_taxonomy() to customize labels, hierarchy,
 * REST exposure, capabilities, and rewrite slug.
 *
 * @see https://developer.wordpress.org/reference/functions/register_taxonomy/
 */
class {{name}} implements CanHandle
{
    public function handle(PHPNomadEvent $event): void
    {
        register_taxonomy('{{taxonomy}}', ['{{objectType}}'], [
            'label' => __('{{pluralLabel}}', '{{textDomain}}'),
            'labels' => [
                'name' => __('{{pluralLabel}}', '{{textDomain}}'),
                'singular_name' => __('{{singularLabel}}', '{{textDomain}}'),
                'add_new_item' => __('Add New {{singularLabel}}', '{{textDomain}}'),
                'edit_item' => __('Edit {{singularLabel}}', '{{textDomain}}'),
                'all_items' => __('All {{pluralLabel}}', '{{textDomain}}'),
                'search_items' => __('Search {{pluralLabel}}', '{{textDomain}}'),
            ],
            'public' => true,
            'show_in_rest' => true,
            'hierarchical' => false,
            // TODO: customize capabilities, rewrite, default_term, taxonomies, etc.
        ]);
    }
}
