#!/bin/bash
netstat -l | egrep "(11000)"
nc -z localhost 11000 && echo "11000 open"
