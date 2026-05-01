<?php

namespace {{namespace}};

use PHPNomad\Events\Interfaces\CanHandle;
use PHPNomad\Events\Interfaces\Event as PHPNomadEvent;

/**
 * Schedules and handles a recurring WP-Cron job.
 *
 * Listens on Ready to: (1) ensure the cron event is scheduled, (2) hook the
 * action handler that runs when the cron fires.
 *
 * Note: WP-Cron only fires when the site receives traffic. For reliable
 * scheduling, configure a real system cron that hits wp-cron.php.
 *
 * @see https://developer.wordpress.org/plugins/cron/
 */
class {{name}} implements CanHandle
{
    public const HOOK = '{{hook}}';
    public const RECURRENCE = '{{recurrence}}';

    public function handle(PHPNomadEvent $event): void
    {
        if (!wp_next_scheduled(self::HOOK)) {
            wp_schedule_event(time(), self::RECURRENCE, self::HOOK);
        }

        add_action(self::HOOK, [$this, 'run']);
    }

    public function run(): void
    {
        // TODO: implement the recurring job's actual work.
        // Keep it lean — long-running jobs should dispatch into PHPNomad tasks instead.
    }
}
