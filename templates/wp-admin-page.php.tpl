<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Adds a top-level admin menu page on admin_menu.
 *
 * Listens on Ready and forwards to admin_menu so the menu registers in the right
 * WordPress lifecycle phase.
 *
 * @see https://developer.wordpress.org/reference/functions/add_menu_page/
 */
class {{name}} implements CanHandle
{
    public function handle(PHPNomadEvent $event): void
    {
        add_action('admin_menu', [$this, 'register']);
    }

    public function register(): void
    {
        add_menu_page(
            __('{{pageTitle}}', '{{textDomain}}'),
            __('{{menuTitle}}', '{{textDomain}}'),
            '{{capability}}',
            '{{menuSlug}}',
            [$this, 'render'],
            '{{iconUrl}}',
            null
        );
    }

    public function render(): void
    {
        if (!current_user_can('{{capability}}')) {
            wp_die(esc_html__('You do not have permission to view this page.', '{{textDomain}}'));
        }

        echo '<div class="wrap">';
        echo '<h1>' . esc_html__('{{pageTitle}}', '{{textDomain}}') . '</h1>';
        // TODO: render the page contents — a settings form, a React mount point, a status table, etc.
        echo '</div>';
    }
}
