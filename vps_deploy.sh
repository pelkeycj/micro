#!/bin/bash

# run from the vps after running deploy.sh locally
# stops current process, unpacks, migrates, and starts
bin/micro stop
tar -xzvf micro.tar.gz &&
bin/micro migrate &&
PORT=8000 bin/micro console &
