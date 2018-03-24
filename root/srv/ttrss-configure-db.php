#!/usr/bin/env php
<?php

include '/srv/ttrss-utils.php';

$confpath = '/var/www/ttrss/';
require_once $confpath . 'config.php';


$config = array();
$config['DB_TYPE'] = DB_TYPE;
$config['DB_HOST'] = DB_HOST;
$config['DB_PORT'] = DB_PORT;
$config['DB_NAME'] = DB_NAME;
$config['DB_USER'] = DB_USER;
$config['DB_PASS'] = DB_PASS;


if (!dbcheck($config)) {
    echo 'Database login failed, trying to create ...' . PHP_EOL;
    // superuser account to create new database and corresponding user account

    $super = $config;

    $super['DB_NAME'] = null;
    $super['DB_USER'] = env('DB_ADMIN_USER', DB_USER);
    $super['DB_PASS'] = env('DB_ADMIN_PASS', DB_PASS);

    $pdo = dbconnect($super);
    $pdo->exec('CREATE ROLE ' . ($config['DB_USER']) . ' WITH LOGIN PASSWORD ' . $pdo->quote($config['DB_PASS']));
    $pdo->exec('CREATE DATABASE ' . ($config['DB_NAME']) . ' WITH OWNER ' . ($config['DB_USER']));
    unset($pdo);

    if (dbcheck($config)) {
        echo 'Database login created and confirmed' . PHP_EOL;
    } else {
        error('Database login failed, trying to create login failed as well');
    }
}

$pdo = dbconnect($config);
try {
    $pdo->query('SELECT 1 FROM ttrss_feeds');
    echo 'Connection to database successful' . PHP_EOL;
    // reached this point => table found, assume db is complete
}
catch (PDOException $e) {
    echo 'Database table not found, applying schema... ' . PHP_EOL;
    $schema = file_get_contents($confpath . 'schema/ttrss_schema_' . $config['DB_TYPE'] . '.sql');
    $schema = preg_replace('/--(.*?);/', '', $schema);
    $schema = preg_replace('/[\r\n]/', ' ', $schema);
    $schema = trim($schema, ' ;');
    foreach (explode(';', $schema) as $stm) {
        $pdo->exec($stm);
    }
    unset($pdo);
}

