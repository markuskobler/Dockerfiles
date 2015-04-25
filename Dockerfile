FROM scratch

ADD etc /etc/
ADD out/haproxy/ /haproxy/
ADD haproxy.cfg /haproxy/haproxy.cfg

WORKDIR /haproxy

ENTRYPOINT [ "/haproxy/haproxy-systemd-wrapper" ]

CMD [ "-f", "/haproxy/haproxy.cfg" ]
