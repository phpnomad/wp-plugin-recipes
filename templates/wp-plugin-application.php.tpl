<?php

namespace {{namespace}};

use PHPNomad\Cache\Traits\WithInstanceCache;
use PHPNomad\Core\Bootstrap\CoreInitializer as PHPNomadCoreInitializer;
use PHPNomad\Di\Container;
use PHPNomad\Integrations\WordPress\Strategies\WordPressInitializer;
use PHPNomad\Loader\Bootstrapper;
use PHPNomad\Loader\Exceptions\LoaderException;

final class Application
{
    use WithInstanceCache;

    public function __construct(
        protected string $file
    ) {
    }

    protected function getContainer(): Container
    {
        return $this->getFromInstanceCache(Container::class, fn() => new Container());
    }

    protected function bootBaseDependencies(): void
    {
        (new Bootstrapper(
            $this->getContainer(),
            new PHPNomadCoreInitializer(),
            new WordPressInitializer(),
            new AppInit(),
        ))->load();
    }

    /**
     * @throws LoaderException
     */
    public function init(): void
    {
        $this->bootBaseDependencies();

        (new Bootstrapper($this->getContainer()))->load();
    }

    /**
     * @throws LoaderException
     */
    public function install(): void
    {
        $this->bootBaseDependencies();

        (new Bootstrapper($this->getContainer()))->load();
    }
}
