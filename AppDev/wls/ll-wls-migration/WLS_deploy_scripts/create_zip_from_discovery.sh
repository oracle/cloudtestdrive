#!/bin/bash
mkdir -p discovery_files && \
mv source* discovery_files/ && \
zip -r discovery_files.zip discovery_files && \
rm -rf discovery_files/