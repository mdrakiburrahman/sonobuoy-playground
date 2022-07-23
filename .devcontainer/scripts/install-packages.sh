#!/usr/bin/env -S bash -e

export DEBIAN_FRONTEND=noninteractive

apt-get update

# # Run install apt-utils to avoid debconf warning then verify presence of other common developer tools and dependencies
PACKAGE_LIST="apt-utils \
    build-essential \
    software-properties-common"

# echo "Packages to verify are installed: ${PACKAGE_LIST}"
apt-get -y install --no-install-recommends ${PACKAGE_LIST} 2> >( grep -v 'debconf: delaying package configuration, since apt-utils is not installed' >&2 )

echo "Installing yq..."
VERSION=v4.25.1
BINARY=yq_linux_386
sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq \
    && sudo chmod +x /usr/bin/yq

echo "Installing Sonobuoy..."
VERSION=0.56.8
wget https://github.com/vmware-tanzu/sonobuoy/releases/download/v${VERSION}/sonobuoy_${VERSION}_linux_amd64.tar.gz
tar -xvf sonobuoy_${VERSION}_linux_amd64.tar.gz
sudo mv sonobuoy /usr/bin
sudo chmod +x /usr/bin/sonobuoy

# Clean up
apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/downloads