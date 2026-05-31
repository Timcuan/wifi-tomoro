#!/bin/bash
# Alias — gunakan ingfo
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ingfo" start "$@"
