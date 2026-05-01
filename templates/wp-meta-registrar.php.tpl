<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Registers the '{{metaKey}}' post meta on the '{{postType}}' post type.
 *
 * Calling register_post_meta() exposes the meta to the REST API and lets WordPress
 * apply the declared type, default value, and sanitize/auth callbacks.
 *
 * @see https://developer.wordpress.org/reference/functions/register_post_meta/
 */
class {{name}} implements CanHandle
{
    public const META_KEY = '{{metaKey}}';

    public function handle(PHPNomadEvent $event): void
    {
        register_post_meta('{{postType}}', self::META_KEY, [
            'type' => '{{metaType}}',
            'description' => __('{{description}}', '{{textDomain}}'),
            'single' => true,
            'show_in_rest' => true,
            'default' => $this->defaultValue(),
            // TODO: customize sanitize_callback and auth_callback as needed.
        ]);
    }

    /**
     * @return mixed
     */
    private function defaultValue(): mixed
    {
        // TODO: replace with the actual default for this meta key.
        return null;
    }
}
