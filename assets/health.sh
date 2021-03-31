#!/bin/bash

if ! fuser -v "${PORT}/tcp" | grep srcds; then
    exit 1
fi
