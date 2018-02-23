#!/bin/sh

source util.sh

repos=()

page=1
while :
do
    { set +x; } 2>/dev/null
    payload=$( curl -s -S $GITHUB_API/orgs/$ORG/repos?page=$page -u $USER:$GITHUB_OAUTH_TOKEN )
    new_repos=($(echo $payload | python3 -c "import sys, json; print(' '.join([r['name'] for r in json.load(sys.stdin)]))"))
    set -x
    repos+=( "${new_repos[@]}" )
    page=$((page + 1))
    if [ -z "${new_repos}" ]; then
        break
    fi
done

for repo in "${repos[@]}"
do
    { set +x; } 2>/dev/null
    payload=$(curl -s -S $GITHUB_API/repos/$ORG/$repo/contributors -u $USER:$GITHUB_OAUTH_TOKEN)
    contributors=($(echo $payload | python3 -c "import sys, json; print(' '.join([r['login'] for r in json.load(sys.stdin)]))"))
    set -x
    for contributor in "${contributors[@]}"
    do
        curl -s -S -X PUT $GITHUB_API/repos/$ORG/$repo/collaborators/$contributor -u $USER:$GITHUB_OAUTH_TOKEN
    done
done
