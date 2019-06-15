# vim:set ft=dockerfile:
#FROM docker.io/alpine
#FROM centos:latest
FROM docker.io/openshift/base-centos7

#VOLUME /data/arenadata/gods1/config /etc/arenadata-grid

COPY repo/ADG_2.6_centos7_adg26-centos7.repo /etc/yum.repos.d

COPY rpm/arenadata-grid-2.7.0-1.noarch.rpm /root/

#RUN yum install arenadata-grid -y \
RUN yum install /root/arenadata-grid-2.7.0-1.noarch.rpm -y  &&  \
    
    yum clean all && \
    
    rm -rf /var/cache/yum/x86_64/7/ /tmp/* /var/log && \

    /usr/bin/mkdir -p /var/run/arenadata-grid && \

    /usr/bin/chown ignite:ignite /var/run/arenadata-grid && \

    /usr/bin/env bash /usr/share/arenadata-grid/bin/service.sh set-firewal && \

    mkdir /var/log/ /var/log/arenadata-grid

COPY config/server-config.xml /etc/arenadata-grid

COPY config/client-config.xml /etc/arenadata-grid

COPY config/ignitevisorcmd.sh /usr/share/arenadata-grid/bin

EXPOSE 11211:11220
EXPOSE 47500:47509
EXPOSE 47100:47109
EXPOSE 47400:47409

CMD [ "/usr/share/arenadata-grid/bin/ignite.sh", "/etc/arenadata-grid/server-config.xml" ]

