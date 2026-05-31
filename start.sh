#!/bin/bash
# Alias kompatibilitas — gunakan ./tomoro untuk perintah lengkap.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tomoro" start "$@"
