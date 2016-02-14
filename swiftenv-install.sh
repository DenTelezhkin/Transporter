#!/usr/bin/env bash

set -e

git clone --depth 1 https://github.com/kylef/swiftenv.git ~/.swiftenv

echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' > "$HOME/.swiftenv/init"
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> "$HOME/.swiftenv/init"
echo 'eval "$(swiftenv init -)"' >> "$HOME/.swiftenv/init"

if [ -f ".swift-version" ] || [ -n "$SWIFTENV_VERSION" ]; then
  export SWIFTENV_ROOT="$HOME/.swiftenv"
  export PATH="$SWIFTENV_ROOT/bin:$PATH"
  eval $(swiftenv init -)
fi
