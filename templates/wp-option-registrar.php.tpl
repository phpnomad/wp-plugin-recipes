<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Ensures the '{{optionName}}' option exists with a default value when the Ready event fires.
 *
 * Idempotent — add_option() is a no-op if the option already exists.
 *
 * @see https://developer.wordpress.org/reference/functions/add_option/
 */
class {{name}} implements CanHandle
{
    public const OPTION_NAME = '{{optionName}}';

    public function handle(PHPNomadEvent $event): void
    {
        if (get_option(self::OPTION_NAME, null) === null) {
            add_option(self::OPTION_NAME, $this->defaultValue(), '', true);
        }
    }

    /**
     * The default option value. Customize this to match your data shape.
     *
     * @return mixed
     */
    private function defaultValue(): mixed
    {
        // TODO: replace with the actual default for this option.
        return [];
    }
}
