#!/bin/sh

mkdir -p ${BUCKET_ROOT}
mkdir -p ${CONFIG_DIR}

cat > ${CONFIG_DIR}/config.json << EOF
{
	"version": "10",
	"credential": {
		"accessKey": "${ACCESS_KEY}",
		"secretKey": "${SECRET_KEY}"
	},
	"region": "${REGION}",
	"logger": {
		"console": {
			"enable": true,
			"level": "error"
		},
		"file": {
			"enable": false,
			"fileName": "",
			"level": ""
		}
	},
	"notify": {
		"amqp": {
			"1": {
				"enable": false,
				"url": "",
				"exchange": "",
				"routingKey": "",
				"exchangeType": "",
				"mandatory": false,
				"immediate": false,
				"durable": false,
				"internal": false,
				"noWait": false,
				"autoDeleted": false
			}
		},
		"nats": {
			"1": {
				"enable": false,
				"address": "",
				"subject": "",
				"username": "",
				"password": "",
				"token": "",
				"secure": false,
				"pingInterval": 0
			}
		},
		"elasticsearch": {
			"1": {
				"enable": false,
				"url": "",
				"index": ""
			}
		},
		"redis": {
			"1": {
				"enable": false,
				"address": "",
				"password": "",
				"key": ""
			}
		},
		"postgresql": {
			"1": {
				"enable": false,
				"connectionString": "",
				"table": "",
				"host": "",
				"port": "",
				"user": "",
				"password": "",
				"database": ""
			}
		}
	}
}
EOF

/minio server -C "${CONFIG_DIR}" "${BUCKET_ROOT}"
