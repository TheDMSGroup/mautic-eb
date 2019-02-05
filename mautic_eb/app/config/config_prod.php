<?php

$loader->import('config.php');

if (file_exists(__DIR__.'/security_local.php')) {
    $loader->import('security_local.php');
} else {
    $loader->import('security.php');
}

// Non-default security settings for mautic-eb.
if ('prod' == $container->getParameter('kernel.environment')) {
    $restrictedConfigFields = $container->getParameter('mautic.security.restrictedConfigFields');
    $container->setParameter('mautic.security.restrictedConfigFields', array_merge($restrictedConfigFields, [
        'tmp_path',
        'log_path',
        'image_path',
        'upload_dir',
        'site_url',
    ]));
    $container->setParameter('mautic.security.disableUpdates', true);
}

// Speed up batch processing at the cost of CPU cycles.
// By default Mautic sleeps 1 full second between batches.
// We'll drop that down to 50ms.
$container->setParameter('mautic.batch_sleep_time', .050);

// Allow up to 3 parallel file imports.
$container->setParameter('mautic.parallel_import_limit', 3);

// Optionally allow CSRF to be disabled. Useful if all users are behind a firewall and you have multiple nodes.
// Just set the environment variable CSRF to 0.
$container->setParameter('mautic.framework.csrf_protection', (bool) getenv('CSRF') ?: true);

// Check for APCu
if (function_exists('apcu_fetch') && class_exists('\Doctrine\Common\Cache\ApcuCache')) {
    /*
     * Disabling APC for validation because of core bug
     * https://github.com/mautic/mautic/issues/6259
     */

    // $container->loadFromExtension('framework', array(
    //     'validation' => array(
    //         'cache' => 'apcu'
    //     )
    // ));

    /*
     * Note this requires a patch for Apcu compatibility.
     * https://github.com/mautic/mautic/pull/7215
     */
    $container->loadFromExtension('doctrine', [
        'orm' => [
            'metadata_cache_driver' => 'apcu',
            'query_cache_driver'    => 'apcu',
            'result_cache_driver'   => 'array',
        ],
    ]);
}

// Read Only db cluster support.
// In future this may be best as a modification of the core config.php.
$dbHostRO = $container->hasParameter('mautic.db_host_ro') ? $container->getParameter('mautic.db_host_ro') : null;
if (!empty($dbHostRO)) {
    // Default from config.php
    $dbalSettings = [
        'driver'   => '%mautic.db_driver%',
        'host'     => '%mautic.db_host%',
        'port'     => '%mautic.db_port%',
        'dbname'   => '%mautic.db_name%',
        'user'     => '%mautic.db_user%',
        'password' => '%mautic.db_password%',
        'charset'  => 'UTF8',
        'types'    => [
            'array'    => 'Mautic\CoreBundle\Doctrine\Type\ArrayType',
            'datetime' => 'Mautic\CoreBundle\Doctrine\Type\UTCDateTimeType',
        ],
        // Prevent Doctrine from crapping out with "unsupported type" errors due to it examining all tables in the database and not just Mautic's
        'mapping_types' => [
            'enum'  => 'string',
            'point' => 'string',
            'bit'   => 'string',
        ],
        'server_version' => '%mautic.db_server_version%',
    ];

    // Add a single slave (which is a load balanced Aurora read-only cluster).
    $dbalSettings['keep_slave'] = true;
    $dbalSettings['slaves']     = [
        'slave1' => [
            'host'     => $dbHostRO,
            'port'     => '%mautic.db_port%',
            'dbname'   => '%mautic.db_name%',
            'user'     => '%mautic.db_user%',
            'password' => '%mautic.db_password%',
            'charset'  => 'UTF8',
        ],
    ];
    $container->loadFromExtension('doctrine', [
        'dbal' => $dbalSettings,
    ]);
}

$debugMode = $container->hasParameter('mautic.debug') ? $container->getParameter('mautic.debug') : $container->getParameter('kernel.debug');

$container->loadFromExtension('monolog', [
    'channels' => [
        'mautic',
    ],
    'handlers' => [
        'main' => [
            'formatter'    => $debugMode ? 'mautic.monolog.fulltrace.formatter' : null,
            'type'         => 'fingers_crossed',
            'buffer_size'  => '200',
            'action_level' => ($debugMode) ? 'debug' : 'error',
            'handler'      => 'nested',
            'channels'     => [
                '!mautic',
            ],
        ],
        'nested' => [
            'type'      => 'rotating_file',
            'path'      => '%kernel.logs_dir%/%kernel.environment%.log',
            'level'     => ($debugMode) ? 'debug' : 'error',
            'max_files' => 7,
        ],
        'mautic' => [
            'formatter' => $debugMode ? 'mautic.monolog.fulltrace.formatter' : null,
            'type'      => 'rotating_file',
            'path'      => '%kernel.logs_dir%/mautic_%kernel.environment%.log',
            'level'     => ($debugMode) ? 'debug' : 'notice',
            'channels'  => [
                'mautic',
            ],
            'max_files' => 7,
        ],
    ],
]);

//Twig Configuration
$container->loadFromExtension('twig', [
    'cache'       => '%mautic.tmp_path%/%kernel.environment%/twig',
    'auto_reload' => true,
]);

// Allow overriding config without a requiring a full bundle or hacks
if (file_exists(__DIR__.'/config_override.php')) {
    $loader->import('config_override.php');
}

// Allow local settings without committing to git such as swift mailer delivery address overrides
if (file_exists(__DIR__.'/config_local.php')) {
    $loader->import('config_local.php');
}
