<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Adds the '{{roleSlug}}' user role on Ready, if it does not already exist.
 *
 * Roles persist in wp_options once added — this is idempotent at runtime.
 * For one-time setup (e.g. on plugin activation) consider running this logic
 * from a register_activation_hook callback instead.
 *
 * @see https://developer.wordpress.org/reference/functions/add_role/
 */
class {{name}} implements CanHandle
{
    public const ROLE_SLUG = '{{roleSlug}}';

    public function handle(PHPNomadEvent $event): void
    {
        if (get_role(self::ROLE_SLUG) instanceof \WP_Role) {
            return;
        }

        add_role(
            self::ROLE_SLUG,
            __('{{roleLabel}}', '{{textDomain}}'),
            $this->capabilities()
        );
    }

    /**
     * Capabilities granted to this role. Customize as your domain requires.
     *
     * @return array<string, bool>
     */
    private function capabilities(): array
    {
        return [
            'read' => true,
            // TODO: add domain-specific capabilities (edit_posts, manage_options, etc.)
        ];
    }
}
