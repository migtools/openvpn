FROM registry.access.redhat.com/ubi8:latest AS builder
RUN echo -e "[almalinux8-baseos]" \
 "\nname = almalinux8-baseos" \
 "\nbaseurl = https://repo.almalinux.org/almalinux/8/BaseOS/\$basearch/os/" \
 "\nenabled = 1" \
 "\ngpgcheck = 0" \
 "\n[almalinux8-appstream]" \
 "\nname = almalinux8-appstream" \
 "\nbaseurl = https://repo.almalinux.org/almalinux/8/AppStream/\$basearch/os/" \
 "\nenabled = 1" \
 "\ngpgcheck = 0" \
 "\n[almalinux8-powertools]" \
 "\nname = almalinux8-powertools" \
 "\nbaseurl = https://repo.almalinux.org/almalinux/8/PowerTools/\$basearch/os/" \
 "\nenabled = 1" \
 "\ngpgcheck = 0" > /etc/yum.repos.d/almalinux.repo
ADD *.rpm .
RUN dnf -y install dnf dnf-plugins-core rpm-build
RUN rpm -ivh *.rpm
RUN dnf builddep -y pkcs11-helper*
RUN rpmbuild -ba /root/rpmbuild/SPECS/pkcs11-helper.spec
RUN dnf -y install /root/rpmbuild/RPMS/x86_64/pkcs11-helper*
RUN dnf builddep -y openvpn*
RUN rpmbuild -ba /root/rpmbuild/SPECS/openvpn.spec

FROM registry.access.redhat.com/ubi8:latest
RUN dnf -y update && dnf -y install cpio lzo socat stunnel && dnf clean all
COPY --from=builder /root/rpmbuild/RPMS/x86_64/pkcs11-helper-1* ./
COPY --from=builder /root/rpmbuild/RPMS/x86_64/openvpn-2* ./
RUN bash -c 'rpm2cpio < pkcs11-helper-1* | cpio -ivd'
RUN bash -c 'rpm2cpio < openvpn-2* | cpio -ivd'
RUN rm -f *.rpm
