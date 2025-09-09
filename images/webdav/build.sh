#!/bin/sh

set -e

docker-install -r -u -c apache2-webdav

mkdir -p /run/apache2

mv /etc/apache2/httpd.conf /etc/apache2/httpd.conf.ORG
cat << 'EOF' > /etc/apache2/httpd.conf
ServerTokens OS
ServerRoot /var/www
Listen 80
HostnameLookups Off

LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule access_compat_module modules/mod_access_compat.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule auth_digest_module modules/mod_auth_digest.so
LoadModule reqtimeout_module modules/mod_reqtimeout.so
LoadModule filter_module modules/mod_filter.so
LoadModule mime_module modules/mod_mime.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule env_module modules/mod_env.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule version_module modules/mod_version.so
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule status_module modules/mod_status.so
LoadModule autoindex_module modules/mod_autoindex.so
LoadModule rewrite_module modules/mod_rewrite.so

LoadModule dav_module modules/mod_dav.so
LoadModule dav_fs_module modules/mod_dav_fs.so
LoadModule dav_lock_module modules/mod_dav_lock.so

<IfModule !mpm_prefork_module>
	#LoadModule cgid_module lib/apache2/mod_cgid.so
</IfModule>

<IfModule mpm_prefork_module>
	#LoadModule cgi_module lib/apache2/mod_cgi.so
</IfModule>

LoadModule dir_module modules/mod_dir.so
LoadModule alias_module modules/mod_alias.so

LoadModule negotiation_module modules/mod_negotiation.so

<IfModule unixd_module>
User apache
Group apache
</IfModule>

ServerAdmin noc@weepee.io

ServerSignature Off

ServerName apache

<Directory />
    AllowOverride None
    Require all denied
</Directory>

DocumentRoot "/data"

DavLockDB /tmp/DavLock

<Directory "/data">
        DAV On
        AuthType Digest
        AuthName "webdav"
        AuthUserFile /etc/apache2/htpasswd
        LimitXMLRequestBody 104857600
        Require valid-user
        Options Indexes FollowSymLinks
		Options FollowSymLinks Includes MultiViews
		AddDefaultCharset utf-8
		IndexOptions Charset=utf-8
		Options +Indexes
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

AccessFileName .htaccess
<Files ".ht*">
    Require all denied
</Files>

ErrorLog "|/bin/cat"

LogLevel warn

<IfModule log_config_module>
    LogFormat "ip %{x-real-ip}i ff,lb %{x-forwarded-for}i ro %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "ip %{x-real-ip}i ff,lb %{x-forwarded-for}i ro %h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      LogFormat "ip %{x-real-ip}i ff,lb %{x-forwarded-for}i ro %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>

		    CustomLog "|/bin/cat" combined
</IfModule>

<IfModule alias_module>
    #ScriptAlias /cgi-bin/ "/var/www/localhost/cgi-bin/"
</IfModule>

<IfModule cgid_module>
    #Scriptsock cgisock
</IfModule>

<Directory "/var/www/localhost/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/apache2/mime.types
  AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
</IfModule>

<IfModule mime_magic_module>
    MIMEMagicFile /etc/apache2/magic
</IfModule>

#IncludeOptional /etc/apache2/conf.d/*.conf
EOF

mkdir -p /data

mkdir -p /usr/local/etc
cp -a /etc/apache2/httpd.conf /usr/local/etc/

