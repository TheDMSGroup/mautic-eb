<?php
//
//
//$debugMode = $container->hasParameter('mautic.debug') ? $container->getParameter('mautic.debug') : $container->getParameter('kernel.debug');
//
//$container->loadFromExtension('monolog', [
//    'channels' => [
//        'mautic',
//    ],
//    'handlers' => [
//        'main' => [
//            'formatter'    => $debugMode ? 'mautic.monolog.fulltrace.formatter' : null,
//            'type'         => 'fingers_crossed',
//            'buffer_size'  => '200',
//            'action_level' => ($debugMode) ? 'debug' : 'error',
//            'handler'      => 'nested',
//            'channels'     => [
//                '!mautic',
//            ],
//        ],
//        'nested' => [
//            'type'      => 'rotating_file',
//            'path'      => '%kernel.logs_dir%/%kernel.environment%.php',
//            'level'     => ($debugMode) ? 'debug' : 'error',
//            'max_files' => 7,
//        ],
//        'mautic' => [
//            'formatter' => $debugMode ? 'mautic.monolog.fulltrace.formatter' : null,
//            'type'      => 'rotating_file',
//            'path'      => '%kernel.logs_dir%/mautic_%kernel.environment%.php',
//            'level'     => ($debugMode) ? 'debug' : 'notice',
//            'channels'  => [
//                'mautic',
//            ],
//            'max_files' => 7,
//        ],
//    ],
//]);
