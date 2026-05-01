<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Enqueues a CSS bundle on the front-end and/or in wp-admin.
 *
 * @see https://developer.wordpress.org/reference/functions/wp_enqueue_style/
 */
class {{name}} implements CanHandle
{
    public const HANDLE = '{{handle}}';

    public function __construct(private readonly string $pluginUrl)
    {
    }

    public function handle(PHPNomadEvent $event): void
    {
        add_action('wp_enqueue_scripts', [$this, 'enqueue']);
        add_action('admin_enqueue_scripts', [$this, 'enqueue']);
    }

    public function enqueue(): void
    {
        if (!$this->shouldEnqueue()) {
            return;
        }

        wp_enqueue_style(
            self::HANDLE,
            $this->pluginUrl . '{{srcPath}}',
            $this->dependencies(),
            '{{version}}'
        );
    }

    private function shouldEnqueue(): bool
    {
        // TODO: gate the stylesheet — e.g. only on certain admin screens or post types.
        return true;
    }

    /**
     * @return string[]
     */
    private function dependencies(): array
    {
        // TODO: declare style handles this stylesheet depends on.
        return [];
    }
}
