#!/bin/sh

addgroup \
	-g $GID \
	-S \
	$USER

adduser \
	-D \
	-G $USER \
	-h /home/$USER \
	-s /bin/false \
	-u $UID \
	$USER

#mkdir -p /home/$USER
chown -R $USER:$USER /var/www/html/
echo "$USER:$PASSWD" | /usr/sbin/chpasswd

touch /var/log/vsftpd.log
tail -f /var/log/vsftpd.log | tee /dev/stdout &
touch /var/log/xferlog
tail -f /var/log/xferlog | tee /dev/stdout &

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

tail -f /dev/null
