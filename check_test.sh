#!/bin/sh

ulimit -c 0
${1};
exit_code=$?
echo "Exit code was ${exit_code}"
if [ ${exit_code} = 0 ]; then
	echo "Ran sucessfully"
	exit 0
else
	echo "Crashed/nonzero exit code"
	exit 1
fi

