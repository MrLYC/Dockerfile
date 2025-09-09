#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

mkdir -p conf/
cat > conf/app.conf << EOF
appname =  ${APPNAME:-webcron}
httpport = ${PORT:-8080}
runmode = ${RUNMODE:-dev}

jobs.pool = ${JOBS_POOL:-10}

site.name = ${SITE_NAME:-WebCron}

db.host = ${DB_HOST:-127.0.0.1}
db.port = ${DB_PORT:-3306}
db.user = ${DB_USER:-root}
db.password = ${DB_PASSWORD:-mrlyc}
db.name = ${DB_NAME:-webcron}
db.prefix = ${DB_PREFIX:-cron_}
db.timezone = ${DB_TIMEZONE:-Asia/Shanghai}

mail.queue_size = ${MAIL_QSIZE:-100}
mail.host = ${MAIL_HOST:-smtp.example.com}
mail.port = ${MAIL_PORT:-25}
mail.from = ${MAIL_FROM:-no-reply@example.com}
mail.user = ${MAIL_USER:-username}
mail.password = ${MAIL_PASSWORD:-password}
EOF

mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p${DB_PASSWORD} ${DB_NAME} < install.sql
webcron
