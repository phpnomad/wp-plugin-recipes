<?php

namespace {{namespace}};

use PHPNomad\Core\Events\Ready;
use PHPNomad\Di\Interfaces\CanSetContainer;
use PHPNomad\Di\Traits\HasSettableContainer;
use PHPNomad\Events\Interfaces\HasEventBindings;
use PHPNomad\Loader\Interfaces\HasClassDefinitions;

class AppInit implements CanSetContainer, HasClassDefinitions, HasEventBindings
{
    use HasSettableContainer;

    /**
     * WordPress can fire `init` more than once. Track first-fire so Ready dispatches once.
     */
    private static bool $initRan = false;

    public function getClassDefinitions(): array
    {
        return [];
    }

    public function getEventBindings(): array
    {
        return [
            Ready::class => [
                ['action' => 'init', 'transformer' => function () {
                    if (self::$initRan) {
                        return null;
                    }

                    self::$initRan = true;
                    return new Ready();
                }],
            ],
        ];
    }
}
