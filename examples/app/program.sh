#!/bin/bash

echo "Sorry, the web server is on vacation"
echo ""
echo "My PID: $$"
echo "My environment"
env

echo
echo "The contents of /app/index.html"
cat /app/index.html
