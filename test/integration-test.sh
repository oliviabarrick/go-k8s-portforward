#!/bin/bash
set -e
set -x

# wait for up to $1 seconds for some command to return true
function wait_for {
    set +x
    set +e

    max_tries=$1
    count=0
    ret=1


    while [ $count -lt $max_tries ] && [ $ret -ne 0 ]; do
        ${@:2}
        ret=$?
        sleep 1
        count=$(($count + 1))
    done

    set -e
    set -x

    return $ret
}

# Wait for a pod to be ready.
function is_ready {
	test ! -z "$(kubectl get pods --field-selector=status.phase==Running -l app=nginx -o 'go-template={{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')"
}

echo Waiting for kubernetes.
wait_for 180 kubectl get pods

echo Creating test resources.
kubectl apply -f test/deployment.yaml

echo Waiting for all expected resources to exist
wait_for 180 is_ready

./portforward -label app=nginx -port 80 -listen 1337 &
PID=$!

wait_for 5 curl http://127.0.0.1:1337/ -svo /dev/null

kill -TERM $PID

echo "######################################################"
echo "############## Exiting with success! #################"
echo "######################################################"
