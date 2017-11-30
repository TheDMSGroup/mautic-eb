<?php


$paths = array_merge($paths, [
    'themes'       => 'themes',
    'assets'       => 'media',
    'asset_prefix' => '',
    'plugins'      => 'plugins',
    'translations' => 'translations',
    'local_config' => '%kernel.root_dir%/config/local.php',
    'root'         => substr($root, 0, -4),
    'app'          => 'app',
    'bundles'      => 'app/bundles',
    'vendor'       => 'vendor',
]);
