#!/bin/bash
sudo chgrp docker /var/run/docker.sock

exec "$@"