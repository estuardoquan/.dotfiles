#!/bin/sh

CA_SERVER=${CA_SERVER:-ca.local}
CA_TRUST=${CA_TRUST:-/etc/pki/ca-trust/source/anchors}
CA_CRT=${CA_CRT:-roots.pem}

curl -k -o ${CA_TRUST}/${CA_CRT} https://${CA_SERVER}/${CA_CRT}

chmod 644 ${CA_TRUST}/${CA_CRT}

update-ca-trust

