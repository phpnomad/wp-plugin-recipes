<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;
use WP_Admin_Bar;

/**
 * Adds an item to the WordPress admin bar.
 *
 * @see https://developer.wordpress.org/reference/hooks/admin_bar_menu/
 */
class {{name}} implements CanHandle
{
    public function handle(PHPNomadEvent $event): void
    {
        add_action('admin_bar_menu', [$this, 'register'], 100);
    }

    public function register(WP_Admin_Bar $bar): void
    {
        if (!$this->shouldRender()) {
            return;
        }

        $bar->add_node([
            'id' => '{{nodeId}}',
            'title' => esc_html__('{{title}}', '{{textDomain}}'),
            'href' => $this->href(),
            'meta' => [
                'title' => esc_attr__('{{tooltip}}', '{{textDomain}}'),
            ],
        ]);
    }

    private function shouldRender(): bool
    {
        // TODO: gate the node — e.g. current_user_can(), specific page, environment.
        return is_user_logged_in();
    }

    private function href(): string
    {
        // TODO: return the actual URL the node should link to.
        return admin_url();
    }
}
