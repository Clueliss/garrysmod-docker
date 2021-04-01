#!/bin/bash

fuser -v "${PORT}/tcp" 2>&1 | grep -q "srcds" || exit 1
