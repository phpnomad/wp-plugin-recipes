<?php

namespace {{namespace}};

/**
 * Typed accessor for the '{{metaKey}}' post meta on the '{{postType}}' post type.
 *
 * Wraps get_post_meta/update_post_meta/delete_post_meta so consumers don't
 * sprinkle string keys across the codebase.
 *
 * @see https://developer.wordpress.org/reference/functions/get_post_meta/
 */
class {{name}}
{
    public const META_KEY = '{{metaKey}}';

    /**
     * Read the meta for a post. Returns the default if absent.
     *
     * @return mixed
     */
    public function get(int $postId): mixed
    {
        $value = get_post_meta($postId, self::META_KEY, true);
        return $value === '' ? $this->defaultValue() : $value;
    }

    /**
     * Write the meta for a post. Returns the updated value's meta_id, true, or false.
     *
     * @param mixed $value
     */
    public function set(int $postId, $value): bool
    {
        return (bool) update_post_meta($postId, self::META_KEY, $value);
    }

    /**
     * Delete the meta for a post.
     */
    public function delete(int $postId): bool
    {
        return delete_post_meta($postId, self::META_KEY);
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
