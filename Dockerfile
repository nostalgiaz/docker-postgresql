FROM jmarin/supervisor
MAINTAINER Davide Setti <davide.setti@gmail.com>

RUN yum -y localinstall http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-1.noarch.rpm

RUN yum -y install postgis2_93 postgresql93-contrib postgresql93-server ; yum clean all

RUN rm -Rf /var/lib/pgsql/9.3/data && su -c "/usr/pgsql-9.3/bin/initdb -D /var/lib/pgsql/9.3/data --encoding=utf8" postgres
RUN su postgres -c "/usr/pgsql-9.3/bin/pg_ctl -D /var/lib/pgsql/9.3/data start" && sleep 1 && /bin/su postgres -c "createuser -d -s -r -l docker" && su postgres -c "psql postgres -c \"ALTER USER docker WITH ENCRYPTED PASSWORD 'docker'\"" && su postgres -c "/usr/pgsql-9.3/bin/pg_ctl -D /var/lib/pgsql/9.3/data stop"

# it doesn't make any sense, but the following line is needed by some users (nostalgiaz)
RUN chown -R postgres: /var/lib/pgsql/9.3/data

RUN echo "host all  all    0.0.0.0/0  trust" >> /var/lib/pgsql/9.3/data/pg_hba.conf
RUN echo "listen_addresses = '*'" >> /var/lib/pgsql/9.3/data/postgresql.conf
RUN echo "port = 5432" >> /var/lib/pgsql/9.3/data/postgresql.conf

ENV PGDATA /var/lib/pgsql/9.3/data

EXPOSE 5432

ADD postgis.sv.conf /etc/supervisor/conf.d/

CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf"]
