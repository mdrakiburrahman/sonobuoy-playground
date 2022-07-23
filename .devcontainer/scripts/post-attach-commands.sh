#!/bin/bash -xe

# For storing kube config
mkdir -p ~/.kube

# Run the user's custom setup scripts
/tmp/scripts/user/user.sh || true

exec "$@"

echo "Post-Attach Commands Complete!"
