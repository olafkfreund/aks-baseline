#!/bin/bash

#!/bin/bash

# Set variables
DOMAIN_NAME_AKS_BASELINE="freundcloud.com"
SUBJECT_ALT_NAME="DNS:bicycle.${DOMAIN_NAME_AKS_BASELINE}"
CERTIFICATE_SUBJECT="/CN=bicycle.${DOMAIN_NAME_AKS_BASELINE}/O=Contoso Bicycle"
TRAFFIK_CERT_SUBJECT="/CN=*.aks-ingress.${DOMAIN_NAME_AKS_BASELINE}/O=Contoso AKS Ingress"

# Generate appgw certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out appgw.crt -keyout appgw.key \
    -subj "${CERTIFICATE_SUBJECT}" \
    -addext "${SUBJECT_ALT_NAME}" \
    -addext "keyUsage = digitalSignature" \
    -addext "extendedKeyUsage = serverAuth"

# Export appgw.pfx from appgw.crt and appgw.key
openssl pkcs12 -export -out appgw.pfx -in appgw.crt -inkey appgw.key -passout pass:

# Convert appgw.pfx to base64
APP_GATEWAY_LISTENER_CERTIFICATE_AKS_BASELINE=$(cat appgw.pfx | base64 | tr -d '\n')

# Print app gateway listener certificate
echo "APP_GATEWAY_LISTENER_CERTIFICATE_AKS_BASELINE: ${APP_GATEWAY_LISTENER_CERTIFICATE_AKS_BASELINE}"

# Generate traefik ingress internal certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out traefik-ingress-internal-aks-ingress-tls.crt -keyout traefik-ingress-internal-aks-ingress-tls.key \
    -subj "${TRAFFIK_CERT_SUBJECT}"



az deployment group create -g rg-bu0001a0008 -f cluster-stamp.bicep -p targetVnetResourceId=${RESOURCEID_VNET_CLUSTERSPOKE_AKS_BASELINE} clusterAdminAadGroupObjectId=${AADOBJECTID_GROUP_CLUSTERADMIN_AKS_BASELINE} a0008NamespaceReaderAadGroupObjectId=${AADOBJECTID_GROUP_A0008_READER_AKS_BASELINE} k8sControlPlaneAuthorizationTenantId=${TENANTID_K8SRBAC_AKS_BASELINE} appGatewayListenerCertificate=${APP_GATEWAY_LISTENER_CERTIFICATE_AKS_BASELINE} aksIngressControllerCertificate=${AKS_INGRESS_CONTROLLER_CERTIFICATE_BASE64_AKS_BASELINE} domainName=${DOMAIN_NAME_AKS_BASELINE} gitOpsBootstrappingRepoHttpsUrl=${GITOPS_REPOURL} gitOpsBootstrappingRepoBranch=${GITOPS_CURRENT_BRANCH_NAME} location=uksouth