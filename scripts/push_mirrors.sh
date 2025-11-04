#!/bin/bash
set -e

REMOTE_MAIN=origin
REMOTE_SC=sourcecraft
REMOTE_GF=gitflic

# Добавление зеркал, если не добавлены
if ! git remote | grep -q $REMOTE_SC; then
  git remote add $REMOTE_SC https://sourcecraft.ru/katya/mesh.git
fi
if ! git remote | grep -q $REMOTE_GF; then
  git remote add $REMOTE_GF https://gitflic.ru/project/katya/mesh.git
fi

# Публикация всех веток и тегов
for R in $REMOTE_MAIN $REMOTE_SC $REMOTE_GF; do
  echo ">>> PUSH to $R ..."
  git push $R --all || true
  git push $R --tags || true
done


