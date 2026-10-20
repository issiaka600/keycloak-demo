# Keycloak du client : image propre, thème embarqué, deux realms importés au démarrage.
# Base : MySQL 8 managée (KC_DB=mysql), TLS terminé par l'ingress de la plateforme.
ARG KC_VERSION=26.8.0

FROM quay.io/keycloak/keycloak:${KC_VERSION} AS builder
ENV KC_DB=mysql \
    KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true
COPY --chown=keycloak:keycloak themes/ /opt/keycloak/themes/
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KC_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
# Les fichiers *.json de ce dossier sont importés par --import-realm.
# Un realm déjà présent en base n'est pas écrasé : l'import ne sert qu'au premier démarrage.
COPY --chown=keycloak:keycloak realms/ /opt/keycloak/data/import/

ENV KC_DB=mysql \
    KC_HTTP_ENABLED=true \
    KC_PROXY_HEADERS=xforwarded

EXPOSE 8080
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm"]
