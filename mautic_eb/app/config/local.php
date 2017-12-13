<?php
/**
 * Global default environment variable overrides for Mautic EB
 */
$parameters = array_merge($parameters ?? [], [
    'db_driver' => 'pdo_mysql',
    'db_table_prefix' => null,
    'db_host' => getenv('DB_HOST') ?: getenv('RDS_HOSTNAME') ?: $parameters['db_host'] ?? '127.0.0.1',
    'db_port' => getenv('DB_PORT') ?: getenv('RDS_PORT') ?: $parameters['db_port'] ?? '3306',
    'db_name' => getenv('DB_NAME') ?: getenv('RDS_DB_NAME') ?: $parameters['db_name'] ?? 'mautic_eb_site_0',
    'db_user' => getenv('DB_USER') ?: getenv('RDS_USERNAME') ?: $parameters['db_user'] ?? 'root',
    'db_password' => getenv('DB_PASSWD') ?: getenv('RDS_PASSWORD') ?: $parameters['db_password'] ?? 'root',
    'mailer_from_name' => getenv('MAILER_FROM_NAME') ?: $parameters['mailer_from_name'] ?? 'Web Developer',
    'mailer_from_email' => getenv('MAILER_FROM_EMAIL') ?: $parameters['mailer_from_email'] ?? 'web@developer.com',
    'mailer_transport' => 'mail',
    'mailer_host' => null,
    'mailer_port' => null,
    'mailer_user' => 'root',
    'mailer_password' => 'root',
    'mailer_encryption' => null,
    'mailer_auth_mode' => null,
    'mailer_spool_type' => 'file',
    'mailer_spool_path' => '%kernel.root_dir%/spool',
    'secret_key' => getenv('SECRET_KEY') ?: '3e29c87bddfbfc8e59d004581da4fa9f5c9fe0a9f1f90a244a38e2e5600c2800',
    'site_url' => getenv('APP_URL') ?: 'http://mautic.loc',
    // Always use the core system tmp path.
    'tmp_path' => '/tmp',
]);