<?php

namespace {{namespace}};

/**
 * Typed accessor for the '{{optionName}}' WordPress option.
 *
 * Wraps get_option/update_option/delete_option so consumers don't sprinkle string
 * keys across the codebase. Customize get/set return shapes once you've decided
 * on the option's data structure.
 *
 * @see https://developer.wordpress.org/reference/functions/get_option/
 */
class {{name}}
{
    public const OPTION_NAME = '{{optionName}}';

    /**
     * Read the option. Returns the default if the option does not exist.
     *
     * @return mixed
     */
    public function get(): mixed
    {
        return get_option(self::OPTION_NAME, $this->defaultValue());
    }

    /**
     * Write the option. Returns true if the value was updated.
     */
    public function set(mixed $value): bool
    {
        return update_option(self::OPTION_NAME, $value);
    }

    /**
     * Delete the option entirely.
     */
    public function delete(): bool
    {
        return delete_option(self::OPTION_NAME);
    }

    /**
     * The default returned when the option is absent.
     *
     * @return mixed
     */
    private function defaultValue(): mixed
    {
        // TODO: replace with the actual default for this option.
        return [];
    }
}
