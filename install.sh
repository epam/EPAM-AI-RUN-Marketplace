helm upgrade dev-aitestmate-redis         aitestmate-redis         --install --namespace dev-aitestmate --set resources.requests.cpu=100m  --set resources.requests.memory=1Gi
helm upgrade dev-aitestmate-rabbitmq      aitestmate-rabbitmq      --install --namespace dev-aitestmate --set resources.requests.cpu=100m  --set resources.requests.memory=1Gi
helm upgrade dev-aitestmate-elasticsearch aitestmate-elasticsearch --install --namespace dev-aitestmate --set resources.requests.cpu=1000m --set resources.requests.memory=6Gi
helm upgrade dev-aitestmate-kibana        aitestmate-kibana        --install --namespace dev-aitestmate --set resources.requests.cpu=200m  --set resources.requests.memory=2Gi
helm upgrade dev-aitestmate-embeddings    aitestmate-embeddings    --install --namespace dev-aitestmate --set resources.requests.cpu=2000m --set resources.requests.memory=4Gi
helm upgrade dev-aitestmate-migrator      aitestmate-migrator      --install --namespace dev-aitestmate --set resources.requests.cpu=50m   --set resources.requests.memory=512Mi
helm upgrade dev-aitestmate-beat          aitestmate-beat          --install --namespace dev-aitestmate --set resources.requests.cpu=100m  --set resources.requests.memory=512Mi
helm upgrade dev-aitestmate-flower        aitestmate-flower        --install --namespace dev-aitestmate --set resources.requests.cpu=100m  --set resources.requests.memory=512Mi
helm upgrade dev-aitestmate-worker        aitestmate-worker        --install --namespace dev-aitestmate --set resources.requests.cpu=2000m --set resources.requests.memory=10Gi --set replicaCount=1
helm upgrade dev-aitestmate-api           aitestmate-api           --install --namespace dev-aitestmate --set resources.requests.cpu=200m  --set resources.requests.memory=1Gi
helm upgrade dev-aitestmate-nginx         aitestmate-nginx         --install --namespace dev-aitestmate --set resources.requests.cpu=100m  --set resources.requests.memory=512Mi
