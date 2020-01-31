# (Optional) Get TLS certificates using cert-manager.

resource "kubernetes_namespace" "cert_manager" {
  count      = var.kubernetes_services.use_cert_manger ? 1 : 0
  depends_on = [var.ow_cluster_ready]
  metadata { name = "cert-manager" }
}

resource "null_resource" "install_cert_manager" {
  count      = var.kubernetes_services.use_cert_manger && var.ow_kubectl_ready ? 1 : 0
  depends_on = [kubernetes_namespace.cert_manager]

  provisioner "local-exec" {
    when    = create
    command = <<EOT
                kubectl apply --validate=false \
                --filename ${var.kubernetes_services.cert_manager_link}
              EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
                kubectl delete Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges \
                --grace-period=0 --all --all-namespaces;
               EOT
  }
}

resource "null_resource" "clusterissuer_cert_manager" {
  count      = var.kubernetes_services.use_cert_manger ? 1 : 0
  depends_on = [null_resource.install_cert_manager]

  provisioner "local-exec" {
    when    = create
    command = <<EOT
                sleep 5m && \
                kubectl apply -f - <<EOF
                  apiVersion: cert-manager.io/v1alpha2
                  kind: ClusterIssuer
                  metadata:
                    namespace: default
                    name: letsencrypt-issuer
                  spec:
                    acme:
                      server: https://acme-v02.api.letsencrypt.org/directory
                      email: ${var.kubes_common_configmap.CERT_ADMIN_EMAIL}
                      privateKeySecretRef:
                        name: letsencrypt-prod
                      solvers:
                        - http01:
                            ingress:
                              name: ${kubernetes_ingress.http_ingress.metadata[0].name}
                          selector: {}
                EOF
           EOT
  }
}

resource "null_resource" "certificate_cert_manager" {
  count      = var.kubernetes_services.use_cert_manger ? 1 : 0
  depends_on = [null_resource.clusterissuer_cert_manager, kubernetes_ingress.http_ingress]

  provisioner "local-exec" {
    when    = create
    command = <<EOT
                sleep 10m && \
                kubectl apply -f - <<EOF
                  apiVersion: cert-manager.io/v1alpha2
                  kind: Certificate
                  metadata:
                    namespace: default
                    name: openwisp-tls-crt
                  spec:
                    secretName: openwisp-tls-secret
                    renewBefore: 12h
                    dnsNames:
                    - ${var.kubes_common_configmap.DASHBOARD_DOMAIN}
                    - ${var.kubes_common_configmap.CONTROLLER_DOMAIN}
                    - ${var.kubes_common_configmap.RADIUS_DOMAIN}
                    - ${var.kubes_common_configmap.TOPOLOGY_DOMAIN}
                    issuerRef:
                      name: letsencrypt-issuer
                      kind: ClusterIssuer
                EOF
           EOT
  }
}

resource "null_resource" "ingress_cert_manager" {
  count      = var.kubernetes_services.use_cert_manger ? 1 : 0
  depends_on = [null_resource.certificate_cert_manager]

  provisioner "local-exec" {
    when    = create
    command = <<EOT
                sleep 10m && \
                kubectl patch ingress/${kubernetes_ingress.http_ingress.metadata[0].name} \
                --patch '{
                    "spec": {
                      "tls": [
                          {
                            "hosts": [
                              "${var.kubes_common_configmap.DASHBOARD_DOMAIN}",
                              "${var.kubes_common_configmap.CONTROLLER_DOMAIN}",
                              "${var.kubes_common_configmap.RADIUS_DOMAIN}",
                              "${var.kubes_common_configmap.TOPOLOGY_DOMAIN}"
                            ], "secretName": "openwisp-tls-secret"
                          }
                      ]
                    }
                  }'
              EOT
  }
}
