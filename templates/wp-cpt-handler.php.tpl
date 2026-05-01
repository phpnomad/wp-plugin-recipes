<?php

namespace {{namespace}};

use {{handlerInterface}};
use {{modelAdapter}};
use PHPNomad\Datamodel\Interfaces\DataModel;
use PHPNomad\Datastore\Exceptions\DatastoreErrorException;
use PHPNomad\Datastore\Exceptions\DuplicateEntryException;
use PHPNomad\Datastore\Exceptions\RecordNotFoundException;
use WP_Post;
use WP_Query;

/**
 * CPT-backed implementation of {{handlerInterfaceShort}}.
 *
 * Translates the typed datastore handler interface into WordPress CRUD against the
 * '{{postType}}' post type. Core post fields (post_title, post_content, post_status,
 * post_author, post_date) are stored on the post itself; everything else is post meta.
 *
 * Customize POST_FIELDS to control which model attributes map to post columns vs meta,
 * then update the adapter's toArray/toModel to match.
 *
 * @see https://developer.wordpress.org/reference/functions/wp_insert_post/
 * @see https://developer.wordpress.org/reference/classes/wp_query/
 */
class {{className}} implements {{handlerInterfaceShort}}
{
    private const POST_TYPE = '{{postType}}';

    /**
     * Model attributes that map to native WP_Post columns rather than post meta.
     * Everything not in this list is treated as post meta.
     *
     * Adjust to match your model. Common additions: 'post_excerpt', 'post_parent',
     * 'menu_order', 'post_name'.
     */
    private const POST_FIELDS = [
        'id',
        'post_title',
        'post_content',
        'post_status',
        'post_author',
        'post_date',
    ];

    public function __construct(private readonly {{modelAdapterShort}} $modelAdapter)
    {
    }

    public function create(array $attributes): DataModel
    {
        [$postArgs, $meta] = $this->splitAttributes($attributes);
        $postArgs['post_type'] = self::POST_TYPE;

        if (!isset($postArgs['post_status'])) {
            $postArgs['post_status'] = 'publish';
        }

        $postId = wp_insert_post($postArgs, true);

        if (is_wp_error($postId)) {
            throw new DatastoreErrorException($postId->get_error_message());
        }

        foreach ($meta as $key => $value) {
            update_post_meta((int) $postId, $key, $value);
        }

        return $this->find($postId);
    }

    public function find($id): DataModel
    {
        $post = get_post((int) $id);

        if (!$post instanceof WP_Post || $post->post_type !== self::POST_TYPE) {
            throw new RecordNotFoundException(sprintf('No %s record found for id %s', self::POST_TYPE, $id));
        }

        return $this->modelAdapter->toModel($this->postToArray($post));
    }

    public function findMultiple(array $ids): array
    {
        if ($ids === []) {
            return [];
        }

        $query = new WP_Query([
            'post_type' => self::POST_TYPE,
            'post__in' => array_map('intval', $ids),
            'posts_per_page' => count($ids),
            'orderby' => 'post__in',
            'no_found_rows' => true,
            'ignore_sticky_posts' => true,
        ]);

        return array_map(
            fn(WP_Post $post): DataModel => $this->modelAdapter->toModel($this->postToArray($post)),
            $query->posts
        );
    }

    public function update($id, array $attributes): void
    {
        $existing = get_post((int) $id);
        if (!$existing instanceof WP_Post || $existing->post_type !== self::POST_TYPE) {
            throw new RecordNotFoundException(sprintf('No %s record found for id %s', self::POST_TYPE, $id));
        }

        [$postArgs, $meta] = $this->splitAttributes($attributes);

        if ($postArgs !== []) {
            $postArgs['ID'] = (int) $id;
            $result = wp_update_post($postArgs, true);
            if (is_wp_error($result)) {
                throw new DatastoreErrorException($result->get_error_message());
            }
        }

        foreach ($meta as $key => $value) {
            update_post_meta((int) $id, $key, $value);
        }
    }

    public function updateCompound(array $ids, array $attributes): void
    {
        // Posts use a single integer primary key, so compound updates degrade to a single update.
        // If you need compound-key semantics here, model the keys as meta and override this.
        if (!isset($ids['id'])) {
            throw new DatastoreErrorException('CPT datastore handlers only support compound updates keyed by "id".');
        }

        $this->update($ids['id'], $attributes);
    }

    public function delete($id): void
    {
        $existing = get_post((int) $id);
        if (!$existing instanceof WP_Post || $existing->post_type !== self::POST_TYPE) {
            throw new RecordNotFoundException(sprintf('No %s record found for id %s', self::POST_TYPE, $id));
        }

        $result = wp_delete_post((int) $id, true);
        if ($result === false || $result === null) {
            throw new DatastoreErrorException(sprintf('Failed to delete %s record %s', self::POST_TYPE, $id));
        }
    }

    public function where(array $conditions, ?int $limit = null, ?int $offset = null, ?string $orderBy = null, string $order = 'ASC'): array
    {
        return $this->runQuery($this->conditionsToQueryArgs($conditions), $limit, $offset, $orderBy, $order);
    }

    public function andWhere(array $conditions, ?int $limit = null, ?int $offset = null, ?string $orderBy = null, string $order = 'ASC'): array
    {
        return $this->where([['type' => 'AND', 'clauses' => $conditions]], $limit, $offset, $orderBy, $order);
    }

    public function orWhere(array $conditions, ?int $limit = null, ?int $offset = null, ?string $orderBy = null, string $order = 'ASC'): array
    {
        return $this->where([['type' => 'OR', 'clauses' => $conditions]], $limit, $offset, $orderBy, $order);
    }

    public function deleteWhere(array $conditions): void
    {
        foreach ($this->andWhere($conditions) as $model) {
            $this->delete($model->id);
        }
    }

    public function findBy(string $field, $value): DataModel
    {
        $results = $this->andWhere([['column' => $field, 'operator' => '=', 'value' => $value]], 1);

        if ($results === []) {
            throw new RecordNotFoundException(sprintf('No %s record found where %s = %s', self::POST_TYPE, $field, (string) $value));
        }

        return $results[0];
    }

    public function getEstimatedCount(): int
    {
        $counts = wp_count_posts(self::POST_TYPE);
        if (!$counts) {
            return 0;
        }

        $total = 0;
        foreach (get_object_vars($counts) as $count) {
            $total += (int) $count;
        }

        return $total;
    }

    public function countWhere(array $conditions): int
    {
        $args = $this->conditionsToQueryArgs([$conditions]);
        $args['post_type'] = self::POST_TYPE;
        $args['posts_per_page'] = 1;
        $args['fields'] = 'ids';
        $args['no_found_rows'] = false;

        $query = new WP_Query($args);

        return (int) $query->found_posts;
    }

    public function countAndWhere(array $conditions): int
    {
        return $this->countWhere(['type' => 'AND', 'clauses' => $conditions]);
    }

    public function countOrWhere(array $conditions): int
    {
        return $this->countWhere(['type' => 'OR', 'clauses' => $conditions]);
    }

    /**
     * Translate a WP_Post into the flat associative array the adapter expects.
     *
     * Customize this if your model exposes additional post columns or computed fields.
     *
     * @return array<string, mixed>
     */
    private function postToArray(WP_Post $post): array
    {
        $data = [
            'id' => $post->ID,
            'post_title' => $post->post_title,
            'post_content' => $post->post_content,
            'post_status' => $post->post_status,
            'post_author' => (int) $post->post_author,
            'post_date' => $post->post_date,
        ];

        // Pull every meta key onto the array. Customize if you only want specific keys.
        foreach (get_post_meta($post->ID) as $key => $values) {
            $data[$key] = is_array($values) && count($values) === 1 ? maybe_unserialize($values[0]) : array_map('maybe_unserialize', $values);
        }

        return $data;
    }

    /**
     * Split an attribute array into (post args, meta values).
     *
     * @param array<string, mixed> $attributes
     * @return array{0: array<string, mixed>, 1: array<string, mixed>}
     */
    private function splitAttributes(array $attributes): array
    {
        $postArgs = [];
        $meta = [];

        foreach ($attributes as $key => $value) {
            if (in_array($key, self::POST_FIELDS, true)) {
                $postArgs[$key] = $value;
            } else {
                $meta[$key] = $value;
            }
        }

        return [$postArgs, $meta];
    }

    /**
     * Translate datastore where-conditions into WP_Query meta_query arguments.
     *
     * @param array{type?: string, clauses: array{column: string, operator: string, value: mixed}[]}[] $conditions
     * @return array<string, mixed>
     */
    private function conditionsToQueryArgs(array $conditions): array
    {
        $metaQuery = [];

        foreach ($conditions as $group) {
            $relation = strtoupper($group['type'] ?? 'AND');
            $clauses = ['relation' => $relation];

            foreach ($group['clauses'] ?? [] as $clause) {
                if (in_array($clause['column'], self::POST_FIELDS, true)) {
                    // TODO: support post-column filters (e.g. post_status) — these go on top-level WP_Query args, not meta_query.
                    continue;
                }

                $clauses[] = [
                    'key' => $clause['column'],
                    'value' => $clause['value'],
                    'compare' => $clause['operator'] ?? '=',
                ];
            }

            if (count($clauses) > 1) {
                $metaQuery[] = $clauses;
            }
        }

        $args = [];
        if ($metaQuery !== []) {
            $args['meta_query'] = ['relation' => 'AND', ...$metaQuery];
        }

        return $args;
    }

    /**
     * @param array<string, mixed> $args
     * @return DataModel[]
     */
    private function runQuery(array $args, ?int $limit, ?int $offset, ?string $orderBy, string $order): array
    {
        $args['post_type'] = self::POST_TYPE;
        $args['posts_per_page'] = $limit ?? -1;
        $args['offset'] = $offset ?? 0;
        $args['no_found_rows'] = true;
        $args['ignore_sticky_posts'] = true;

        if ($orderBy !== null) {
            $args['orderby'] = in_array($orderBy, self::POST_FIELDS, true) ? $orderBy : 'meta_value';
            if (!in_array($orderBy, self::POST_FIELDS, true)) {
                $args['meta_key'] = $orderBy;
            }
            $args['order'] = strtoupper($order);
        }

        $query = new WP_Query($args);

        return array_map(
            fn(WP_Post $post): DataModel => $this->modelAdapter->toModel($this->postToArray($post)),
            $query->posts
        );
    }
}
