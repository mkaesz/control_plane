#!/bin/bash
echo "Creating custom issue file for $1"

echo "Welcome to Clear Linux*!

This is a custom image created by mkaesz.

" >> $1/etc/issue

exit 0

