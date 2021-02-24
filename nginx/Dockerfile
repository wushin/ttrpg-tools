FROM nginx:latest

RUN apt-get update && apt-get install -y sudo certbot python-certbot-nginx ssl-cert cron procps
RUN groupadd -g 1000 admin
RUN echo "%admin	ALL=(ALL:ALL)	NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -u 1000 -g 1000 -d /var/www/ admin -s /bin/bash
RUN echo "00 0 1 * * certbot -n renew" | crontab -
RUN echo "healthy" > /usr/share/nginx/html/nginx-health

COPY ./certbot.sh.template /var/www/
COPY ./files/ /etc/nginx/
RUN chown admin:admin -R /var/www/

ARG ht_pass
ARG ht_user
ARG ht_dm_pass
ARG ht_dm_user

RUN echo -n $ht_user':' >> /var/.htpasswd
RUN openssl passwd -apr1 passin `echo "$ht_pass"` | tail -n1 >> /var/.htpasswd
RUN echo -n $ht_dm_user':' >> /var/.htpasswd_dm
RUN openssl passwd -apr1 passin `echo "$ht_dm_pass"` | tail -n1 >> /var/.htpasswd_dm
EXPOSE 80
EXPOSE 443
