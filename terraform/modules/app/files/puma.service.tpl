[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=sologm
WorkingDirectory=/home/sologm/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always
Environment='DATABASE_URL=${mongodb_ip}:27017'

[Install]
WantedBy=multi-user.target
