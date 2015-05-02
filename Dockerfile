FROM scratch

ADD etc          /etc/
ADD out/haproxy/ /bin/
ADD haproxy.cfg  /haproxy/haproxy.cfg

WORKDIR /haproxy

ENTRYPOINT ["/bin/haproxy-systemd-wrapper"]

CMD ["-f", "/haproxy/haproxy.cfg", "-p", "/haproxy/haproxy.pid"]
