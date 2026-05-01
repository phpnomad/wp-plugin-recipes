<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Registers the [{{shortcodeTag}}] shortcode.
 *
 * Listens on Ready and calls add_shortcode. The render method receives the parsed
 * attributes, the inner content (for enclosing shortcodes), and the tag name.
 *
 * @see https://developer.wordpress.org/reference/functions/add_shortcode/
 */
class {{name}} implements CanHandle
{
    public const TAG = '{{shortcodeTag}}';

    public function handle(PHPNomadEvent $event): void
    {
        add_shortcode(self::TAG, [$this, 'render']);
    }

    /**
     * @param array<string, string>|string $atts
     */
    public function render(array|string $atts = [], ?string $content = null, string $tag = ''): string
    {
        $atts = shortcode_atts($this->defaults(), is_array($atts) ? $atts : [], self::TAG);

        ob_start();
        // TODO: render the shortcode output. Echoed HTML is captured by ob_get_clean().
        echo '<div class="acme-shortcode" data-tag="' . esc_attr(self::TAG) . '">';
        echo esc_html(sprintf(__('Rendering [%s]', '{{textDomain}}'), self::TAG));
        echo '</div>';

        return (string) ob_get_clean();
    }

    /**
     * @return array<string, string>
     */
    private function defaults(): array
    {
        return [
            // TODO: declare default attribute values here.
        ];
    }
}
