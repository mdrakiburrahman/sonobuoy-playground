# Login to Azure and get Kubeconfig
az login --use-device-code
az account set --subscription "AIA - Azure Internal Subscription"
az aks get-credentials --resource-group sonobuoy-te_group --name sonobuoy-test
kubectl get nodes
# NAME                                STATUS   ROLES   AGE   VERSION
# aks-agentpool-16430811-vmss000002   Ready    agent   46m   v1.23.8

# Login to Docker Hub for image push
export DOCKER_PASS='...'
docker login -u mdrrakiburrahman -p ${DOCKER_PASS}

# Build the plugin container
cd examples/cmd-runner
docker build . -t mdrrakiburrahman/cmd-runner:v0.1
docker push mdrrakiburrahman/cmd-runner:v0.1

# Generate the plugin yaml
sonobuoy gen plugin \
--name=cmd-runner \
--image mdrrakiburrahman/cmd-runner:v0.1 \
--arg="echo ➡️ Running a command!" \
--arg="kubectl cluster-info" \
--arg="kubectl auth can-i get pods" \
--arg="echo ➡️ Done!" > cmd-runner.yaml

# Watch for pods
watch kubectl get pods -A

# Deploy plugin
sonobuoy run --plugin cmd-runner.yaml

# Grab results as tar file
outfile=$(sonobuoy retrieve) && \
mkdir results && tar -xf $outfile -C results

# Untar and print
cat results/plugins/cmd-runner/results/global/out*
# ➡️ Running a command!
# Kubernetes control plane is running at https://10.0.0.1:443
# CoreDNS is running at https://10.0.0.1:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
# Metrics-server is running at https://10.0.0.1:443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

# To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
# yes
# ➡️ Done!