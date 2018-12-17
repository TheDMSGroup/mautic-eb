<?php
/**
 * Global default environment variable overrides for Mautic EB
 * To override for your instance use parameters_local.php
 */
$parameters = [
    'db_driver'           => 'pdo_mysql',
    'db_table_prefix'     => null,
    'db_host'             => getenv('DB_HOST') ?: $parameters['db_host'] ?? '127.0.0.1',
    'db_host_ro'          => getenv('DB_HOST_RO') ?: null,
    'db_port'             => getenv('DB_PORT') ?: $parameters['db_port'] ?? '3306',
    'db_name'             => getenv('DB_NAME') ?: $parameters['db_name'] ?? 'mautic_eb_site_0',
    'db_user'             => getenv('DB_USER') ?: $parameters['db_user'] ?? 'root',
    'db_password'         => getenv('DB_PASSWD') ?: $parameters['db_password'] ?? '',
    'mailer_from_name'    => getenv('MAILER_FROM_NAME') ?: $parameters['mailer_from_name'] ?? 'Web Developer',
    'mailer_from_email'   => getenv('MAILER_FROM_EMAIL') ?: $parameters['mailer_from_email'] ?? 'web@developer.com',
    'secret_key'          => getenv('SECRET_KEY') ?: '3e29c87bddfbfc8e59d004581da4fa9f5c9fe0a9f1f90a244a38e2e5600c2800',
    'site_url'            => getenv('APP_URL') ?: 'http://mautic.loc',
    // Supported by PR #6962
    'import_path'         => '/tmp/imports',
    'tmp_path'            => '%kernel.root_dir%/cache',
    'cache_path'          => '%kernel.root_dir%/cache',
];
/**
 * Multisite environment variable overrides based on the inbound domain.
 *
 * APCu required for performance.
 * Low level logic is intentional since we are in a bootstrap requirement.
 */
if (!function_exists('mauticEBMultisite')) {
    function mauticEBMultisite(&$parameters)
    {
        if (
            boolval(getenv('EB_MULT'))
            && isset($_SERVER['HTTP_HOST'])
        ) {
            $site = null;
            $host = strtolower(filter_var($_SERVER['HTTP_HOST'], FILTER_SANITIZE_URL));
            $key  = 'mautic_eb_mult_host_'.$host;
            if (isset($GLOBALS['mautic_eb_mult_site'])) {
                $site = $GLOBALS['mautic_eb_mult_site'];
            }
            if (!$site && function_exists('apcu_fetch')) {
                $site = apcu_fetch($key);
            }
            if (!$site) {
                // Get parameters for the multi-site MySQL database.
                // Optionally allow a completely different connection for this data.
                $ebParams = [
                    'db_host'     => getenv('EB_MULTI_DB_HOST') ?: $parameters['db_host'],
                    'db_port'     => getenv('EB_MULTI_DB_PORT') ?: $parameters['db_port'],
                    'db_name'     => getenv('EB_MULTI_DB_NAME') ?: 'mautic_eb_multi',
                    'db_user'     => getenv('EB_MULTI_DB_USER') ?: $parameters['db_user'],
                    'db_password' => getenv('EB_MULTI_DB_PASSWD') ?: $parameters['db_password'],
                ];
                if (!is_string($ebParams['db_host']) || !is_string($ebParams['db_user']) || !is_string(
                        $ebParams['db_password']
                    ) || !is_string($ebParams['db_name']) || !is_string($ebParams['db_port'])) {
                    throw \Exception('Invalid site host parameters.');
                }
                $mysqli = new mysqli(
                    $ebParams['db_host'], $ebParams['db_user'], $ebParams['db_password'],
                    $ebParams['db_name'], $ebParams['db_port']
                );
                if (mysqli_connect_error()) {
                    throw \Exception('Unable to connect to EB_MULTI host.', mysqli_connect_error());
                } else {
                    $query  = "SELECT `sites`.* FROM `hosts` LEFT JOIN `sites` ON `hosts`.`site_id` = `sites`.`id` WHERE `hosts`.`host` = '".$mysqli->real_escape_string(
                            $host
                        )."' LIMIT 1;";
                    $result = $mysqli->query($query);
                    if (!$result) {
                        throw \Exception('This domain is not currently supported.');
                    } else {
                        $array = $result->fetch_array();
                        // 0 = waiting for install, 1 = creating storage, 2 = creating database, 3 = running, 4 = halted, 5 = waiting to resume, 6 = waiting for decommission, 7 = decommission
                        switch ($array['status']) {
                            case 0:
                                throw \Exception('This site is awaiting setup.');
                            case 1:
                                throw \Exception('Storage is being allocated for this site.');
                            case 2:
                                throw \Exception('A database is being created for this site.');
                            case 3:
                                // Site is running and enabled.
                                $site = $array;
                                break;
                            case 4:
                                throw \Exception('This site has been temporarily disabled.');
                            case 5:
                                throw \Exception('This site is being restored to active duty.');
                            case 6:
                                throw \Exception('This site is being decommissioned permanently.');
                            case 7:
                                throw \Exception('This site has been decommissioned permanently.');
                        }
                    }
                }
                // Cache this site locally in APCu for quicker retrieval.
                if ($site && function_exists('apcu_store')) {
                    apcu_store($key, $site, 300);
                }
                $GLOBALS['mautic_eb_mult_site'] = $site;
            }
            // If we have discerned the site, and it is active, it changes our parameters from the default.
            if ($site) {
                if ($_COOKIE['EB_MULTI_SITE_ID'] !== $site['id']) {
                    // Global cookie for route filtering at the apache level for later security.
                    setcookie('EB_MULTI_SITE_ID', $site['id'], time() + 604800, '/', $site['host'], false, false);
                }
                // Override parameters array with the JSON array in the parameters column if possible.
                if (!empty($site['parameters'])) {
                    $jsonParams = json_decode($site['parameters']);
                    if (!$jsonParams || !is_array($jsonParams)) {
                        throw \Exception('The custom parameters for this site are malformed.');
                    } else {
                        $parameters = array_merge($parameters, $jsonParams);
                    }
                }
                // Set the path for log entry output.
                $parameters['log_path'] = 'multi/'.$site['id'].'/logs';
                // Set the path for images.
                $parameters['image_path'] = 'multi/'.$site['id'].'/media/images';
                // Set the path for generic uploads.
                $parameters['upload_dir'] = 'multi/'.$site['id'].'/media/files';
                // Set the database name.
                $parameters['db_name'] = 'mautic_eb_site_'.$site['id'];
                // Explicitly set the site URL based on the inbound host, allow flexible SSL.
                if (
                    isset($_SERVER['HTTP_X_FORWARDED_PROTO'])
                    && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https'
                ) {
                    $_SERVER['HTTPS'] = 'on';
                }
                $protocol               = (!empty($_SERVER['HTTPS']) && strtolower(
                        $_SERVER['HTTPS']
                    ) != 'off') ? 'https' : 'http';
                $parameters['site_url'] = $protocol.'://'.$host;
            }
        }
    }
}
mauticEBMultisite($parameters);
