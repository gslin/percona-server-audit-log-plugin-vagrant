#!/bin/sh

work() {
    apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
    sed -i -e 's@http://archive.ubuntu.com@http://tw.archive.ubuntu.com@' /etc/apt/sources.list

    cat > /etc/apt/sources.list.d/percona.list <<EOF
deb http://repo.percona.com/apt precise main
deb-src http://repo.percona.com/apt precise main
EOF

    apt-get update

    DEBIAN_FRONTEND=noninteractive apt-get -y install git vim-nox
    DEBIAN_FRONTEND=noninteractive apt-get -y install percona-server-server-5.5

    echo 'INSTALL PLUGIN audit_log SONAME "audit_log.so";' | mysql -u root

    service mysql stop

    mv /var/lib/mysql /srv/mysql
    ln -s /srv/mysql /var/lib/mysql

    cat > /etc/mysql/my.cnf <<EOF
[mysqld]
binlog_format = ROW
character_set_server = utf8mb4
collation_server = utf8mb4_general_ci
datadir = /var/lib/mysql
default_storage_engine = InnoDB
expire_logs_days = 7
innodb_autoinc_lock_mode = 2
innodb_buffer_pool_size = 64M
innodb_data_file_path = ibdata1:64M;ibdata2:64M:autoextend
innodb_file_format = Barracuda
innodb_file_per_table
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
innodb_locks_unsafe_for_binlog = 1
innodb_log_file_size = 64M
innodb_print_all_deadlocks = 1
innodb_stats_on_metadata = FALSE
innodb_support_xa = FALSE
log-bin = mysqld-bin
log-queries-not-using-indexes
log-slave-updates
long_query_time = 1
max_allowed_packet = 64M
max_connect_errors = 4294967295
max_connections = 32
port = 3306
relay_log_recovery = TRUE
skip-name-resolve
slow_query_log = 1
transaction_isolation = REPEATABLE-READ
user = mysql
wait_timeout = 60
#
# XXX You *MUST* change!
server-id = 1
EOF

    rm /srv/mysql/ib*
    chown -R mysql:mysql /srv/mysql
}

work
