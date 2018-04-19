#!/bin/bash

mv /tmp/puma-reddit.service /etc/systemd/system/puma-reddit.service
chmod 664 /etc/systemd/system/puma-reddit.service
chown root: /etc/systemd/system/puma-reddit.service

systemctl enable puma-reddit
