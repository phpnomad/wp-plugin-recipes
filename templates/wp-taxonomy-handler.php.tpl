<?php

namespace {{namespace}};

use {{handlerInterface}};
use {{modelAdapter}};
use PHPNomad\Datastore\Interfaces\DataModel;
use PHPNomad\Datastore\Exceptions\DatastoreErrorException;
use PHPNomad\Datastore\Exceptions\DuplicateEntryException;
use PHPNomad\Datastore\Exceptions\RecordNotFoundException;
use WP_Term;
use WP_Term_Query;

/**
 * Taxonomy-backed implementation of {{handlerInterfaceShort}}.
 *
 * Translates the typed datastore handler interface into WordPress CRUD against the
 * '{{taxonomy}}' taxonomy. Core term fields (name, slug, description, parent) are stored
 * on the term itself; everything else is term meta.
 *
 * Customize TERM_FIELDS to control which model attributes map to term columns vs meta,
 * then update the adapter's toArray/toModel to match.
 *
 * @see https://developer.wordpress.org/reference/functions/wp_insert_term/
 * @see https://developer.wordpress.org/reference/classes/wp_term_query/
 */
class {{className}} implements {{handlerInterfaceShort}}
{
    private const TAXONOMY = '{{taxonomy}}';

    /**
     * Model attributes that map to native WP_Term columns rather than term meta.
     * Everything not in this list is treated as term meta.
     */
    private const TERM_FIELDS = [
        'id',
        'name',
        'slug',
        'description',
        'parent',
    ];

    public function __construct(private readonly {{modelAdapterShort}} $modelAdapter)
    {
    }

    public function create(array $attributes): DataModel
    {
        if (!isset($attributes['name'])) {
            throw new DatastoreErrorException('Cannot create taxonomy term without a "name" attribute.');
        }

        [$termArgs, $meta] = $this->splitAttributes($attributes);
        $name = $termArgs['name'];
        unset($termArgs['name']);

        $result = wp_insert_term($name, self::TAXONOMY, $termArgs);

        if (is_wp_error($result)) {
            if ($result->get_error_code() === 'term_exists') {
                throw new DuplicateEntryException($result->get_error_message());
            }
            throw new DatastoreErrorException($result->get_error_message());
        }

        $termId = (int) $result['term_id'];

        foreach ($meta as $key => $value) {
            update_term_meta($termId, $key, $value);
        }

        return $this->find($termId);
    }

    public function find($id): DataModel
    {
        $term = get_term((int) $id, self::TAXONOMY);

        if (!$term instanceof WP_Term) {
            throw new RecordNotFoundException(sprintf('No %s term found for id %s', self::TAXONOMY, $id));
        }

        return $this->modelAdapter->toModel($this->termToArray($term));
    }

    public function findMultiple(array $ids): array
    {
        if ($ids === []) {
            return [];
        }

        $query = new WP_Term_Query([
            'taxonomy' => self::TAXONOMY,
            'include' => array_map('intval', $ids),
            'hide_empty' => false,
        ]);

        return array_map(
            fn(WP_Term $term): DataModel => $this->modelAdapter->toModel($this->termToArray($term)),
            $query->terms ?? []
        );
    }

    public function update($id, array $attributes): void
    {
        $existing = get_term((int) $id, self::TAXONOMY);
        if (!$existing instanceof WP_Term) {
            throw new RecordNotFoundException(sprintf('No %s term found for id %s', self::TAXONOMY, $id));
        }

        [$termArgs, $meta] = $this->splitAttributes($attributes);

        if ($termArgs !== []) {
            $result = wp_update_term((int) $id, self::TAXONOMY, $termArgs);
            if (is_wp_error($result)) {
                throw new DatastoreErrorException($result->get_error_message());
            }
        }

        foreach ($meta as $key => $value) {
            update_term_meta((int) $id, $key, $value);
        }
    }

    public function updateCompound(array $ids, array $attributes): void
    {
        if (!isset($ids['id'])) {
            throw new DatastoreErrorException('Taxonomy datastore handlers only support compound updates keyed by "id".');
        }

        $this->update($ids['id'], $attributes);
    }

    public function delete($id): void
    {
        $existing = get_term((int) $id, self::TAXONOMY);
        if (!$existing instanceof WP_Term) {
            throw new RecordNotFoundException(sprintf('No %s term found for id %s', self::TAXONOMY, $id));
        }

        $result = wp_delete_term((int) $id, self::TAXONOMY);
        if (is_wp_error($result) || $result === false || $result === 0) {
            throw new DatastoreErrorException(sprintf('Failed to delete %s term %s', self::TAXONOMY, $id));
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
            $this->delete($model->getId());
        }
    }

    public function findBy(string $field, $value): DataModel
    {
        $results = $this->andWhere([['column' => $field, 'operator' => '=', 'value' => $value]], 1);

        if ($results === []) {
            throw new RecordNotFoundException(sprintf('No %s term found where %s = %s', self::TAXONOMY, $field, (string) $value));
        }

        return $results[0];
    }

    public function getEstimatedCount(): int
    {
        $count = wp_count_terms(['taxonomy' => self::TAXONOMY, 'hide_empty' => false]);
        return is_wp_error($count) ? 0 : (int) $count;
    }

    public function countWhere(array $conditions): int
    {
        $args = $this->conditionsToQueryArgs([$conditions]);
        $args['taxonomy'] = self::TAXONOMY;
        $args['hide_empty'] = false;
        $args['fields'] = 'count';

        $query = new WP_Term_Query($args);

        return (int) $query->terms;
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
     * @return array<string, mixed>
     */
    private function termToArray(WP_Term $term): array
    {
        $data = [
            'id' => $term->term_id,
            'name' => $term->name,
            'slug' => $term->slug,
            'description' => $term->description,
            'parent' => (int) $term->parent,
        ];

        foreach (get_term_meta($term->term_id) as $key => $values) {
            $data[$key] = is_array($values) && count($values) === 1 ? maybe_unserialize($values[0]) : array_map('maybe_unserialize', $values);
        }

        return $data;
    }

    /**
     * @param array<string, mixed> $attributes
     * @return array{0: array<string, mixed>, 1: array<string, mixed>}
     */
    private function splitAttributes(array $attributes): array
    {
        $termArgs = [];
        $meta = [];

        foreach ($attributes as $key => $value) {
            if (in_array($key, self::TERM_FIELDS, true)) {
                $termArgs[$key] = $value;
            } else {
                $meta[$key] = $value;
            }
        }

        return [$termArgs, $meta];
    }

    /**
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
                if (in_array($clause['column'], self::TERM_FIELDS, true)) {
                    // TODO: support term-column filters (slug, parent) — these go on top-level WP_Term_Query args.
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
        $args['taxonomy'] = self::TAXONOMY;
        $args['hide_empty'] = false;
        $args['number'] = $limit ?? 0;
        $args['offset'] = $offset ?? 0;

        if ($orderBy !== null) {
            $args['orderby'] = in_array($orderBy, self::TERM_FIELDS, true) ? $orderBy : 'meta_value';
            if (!in_array($orderBy, self::TERM_FIELDS, true)) {
                $args['meta_key'] = $orderBy;
            }
            $args['order'] = strtoupper($order);
        }

        $query = new WP_Term_Query($args);

        return array_map(
            fn(WP_Term $term): DataModel => $this->modelAdapter->toModel($this->termToArray($term)),
            $query->terms ?? []
        );
    }
}
