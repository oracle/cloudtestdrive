cat<<'EOF'>Dockerfile_7slim
FROM scratch
LABEL "org.opencontainers.image.authors"="Oracle Linux Product Team <ol-ovm-info_ww@oracle.com>" \
      "org.opencontainers.image.url"="https://github.com/oracle/container-images" \
      "org.opencontainers.image.source"="https://github.com/oracle/container-images/tree/dist-amd64/7-slim" \
      "org.opencontainers.image.vendor"="Oracle America, Inc" \
      "org.opencontainers.image.title"="Oracle Linux 7 (slim)" \
      "org.opencontainers.image.description"="Oracle Linux is an open-source \
      operating system available under the GNU General Public License (GPLv2) and \
      is suitable for both general purpose or Oracle workloads."

ADD oraclelinux-7-slim-amd64-rootfs.tar.xz /

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
EOF


time DOCKER_BUILDKIT=1  docker image build  \
--force-rm=true \
--squash \
--rm=true \
--file Dockerfile_7slim .