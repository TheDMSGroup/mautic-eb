<?php
/**
 * Override internal paths when multisite is in use.
 */
if (is_defined('EB_MULTI_PATH')) {
    $paths = array_merge($paths, [
        // @todo - folders must be created and permissions set for new sites.
        'themes'       => EB_MULTI_PATH . '/themes',
        'assets'       => EB_MULTI_PATH . '/media',
        'local_config' => EB_MULTI_PATH . '/config/local.php',
    ]);
}