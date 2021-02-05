FROM nginx:latest

RUN apt-get update && apt-get install -y sudo certbot python-certbot-nginx ssl-cert cron
RUN groupadd -g 1000 admin
RUN echo "%admin	ALL=(ALL:ALL)	NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -u 1000 -g 1000 -d /var/www/ admin
RUN echo "00 0 1 * * certbot -n renew" | crontab -

COPY ./certbot.sh.template /var/www/
RUN chown admin:admin -R /var/www/

ARG ht_pass
ARG ht_user
ARG ht_dm_pass
ARG ht_dm_user

RUN echo -n $ht_user':' >> /var/.htpasswd
RUN openssl passwd -apr1 passin `echo "$ht_pass"` | tail -n1 >> /var/.htpasswd
RUN echo -n $ht_dm_user':' >> /var/.htpasswd_dm
RUN openssl passwd -apr1 passin `echo "$ht_dm_pass"` | tail -n1 >> /var/.htpasswd_dm
