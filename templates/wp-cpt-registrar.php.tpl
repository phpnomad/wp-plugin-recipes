<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Registers the {{postType}} custom post type when the Ready event fires.
 *
 * Edit the array passed to register_post_type() to customize labels, capabilities,
 * supports, REST exposure, and other behavior.
 *
 * @see https://developer.wordpress.org/reference/functions/register_post_type/
 */
class {{name}} implements CanHandle
{
    public function handle(PHPNomadEvent $event): void
    {
        register_post_type('{{postType}}', [
            'label' => __('{{pluralLabel}}', '{{textDomain}}'),
            'labels' => [
                'name' => __('{{pluralLabel}}', '{{textDomain}}'),
                'singular_name' => __('{{singularLabel}}', '{{textDomain}}'),
                'add_new_item' => __('Add New {{singularLabel}}', '{{textDomain}}'),
                'edit_item' => __('Edit {{singularLabel}}', '{{textDomain}}'),
                'view_item' => __('View {{singularLabel}}', '{{textDomain}}'),
                'all_items' => __('All {{pluralLabel}}', '{{textDomain}}'),
                'search_items' => __('Search {{pluralLabel}}', '{{textDomain}}'),
            ],
            'public' => true,
            'show_in_rest' => true,
            'has_archive' => true,
            'supports' => ['title', 'editor', 'thumbnail'],
            // TODO: customize capability_type, taxonomies, menu_icon, menu_position, etc.
        ]);
    }
}
