#!/bin/sh -ex

TOOL_NAME="woodpk"

TOOL_DIR=`dirname "$0"`
TOOL_PATH="$TOOL_DIR/$TOOL_NAME"

INSTALL_DIR=`dirname "$INSTALL_PATH"`
INSTALL_PATH="/usr/local/bin/$TOOL_NAME"
mkdir -p "$INSTALL_DIR"

ln -sf "$TOOL_PATH" "$INSTALL_PATH"

printf "🎉 Install tool done, try 'woodpk info'"
