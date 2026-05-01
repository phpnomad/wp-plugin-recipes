<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Renders an admin notice in wp-admin.
 *
 * Listens on Ready and hooks admin_notices. Add conditional logic to shouldRender()
 * to decide when the notice appears (current screen, capability, dismissed flag, etc.).
 *
 * @see https://developer.wordpress.org/reference/hooks/admin_notices/
 */
class {{name}} implements CanHandle
{
    public function handle(PHPNomadEvent $event): void
    {
        add_action('admin_notices', [$this, 'render']);
    }

    public function render(): void
    {
        if (!$this->shouldRender()) {
            return;
        }

        printf(
            '<div class="notice notice-%1$s is-dismissible"><p>%2$s</p></div>',
            esc_attr('{{noticeType}}'),
            esc_html__('{{message}}', '{{textDomain}}')
        );
    }

    private function shouldRender(): bool
    {
        // TODO: gate the notice — e.g. current_user_can(), get_current_screen(), or a stored "dismissed" option.
        return true;
    }
}
