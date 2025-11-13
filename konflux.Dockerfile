FROM registry.redhat.io/ubi8/ubi:latest AS builder

USER root
ADD *.rpm .
RUN dnf -y install dnf dnf-plugins-core rpm-build
RUN rpm -ivh *.rpm
RUN dnf builddep -y pkcs11-helper*
RUN rpmbuild -ba /root/rpmbuild/SPECS/pkcs11-helper.spec
RUN dnf -y install /root/rpmbuild/RPMS/x86_64/pkcs11-helper*
RUN dnf builddep -y --skip-broken --nobest openvpn*
RUN rpmbuild -ba /root/rpmbuild/SPECS/openvpn.spec

FROM registry.redhat.io/ubi8/ubi:latest
COPY --from=builder /root/rpmbuild/RPMS/x86_64/pkcs11-helper-1* ./
COPY --from=builder /root/rpmbuild/RPMS/x86_64/openvpn-2* ./
COPY LICENSE /licenses/
RUN dnf -y install cpio lzo socat stunnel && dnf clean all
RUN bash -c 'rpm2cpio < pkcs11-helper-1* | cpio -ivd'
RUN bash -c 'rpm2cpio < openvpn-2* | cpio -ivd'
RUN rm -fv *.rpm

LABEL \
        "io.k8s.description"="Migration Toolkit for Containers OpenVPN" \
        "io.k8s.display-name"="Migration Toolkit for Containers" \
        "io.openshift.tags"="migration" \
        "summary"="Migration Toolkit for Containers OpenVPN" \
        "io.openshift.maintainer.project"="MIG"
