#!/bin/bash -eu

function red_echo() {
    echo -e "\033[31m$@\033[0m"
}

function green_echo() {
    echo -e "\033[32m$@\033[0m"
}

image=$1
error_code=0

for cmd in convert ffmpeg ; do
	path=$(docker run --rm $image which $cmd)
	if [[ "$path" == '' ]]; then
		red_echo "[Failed] Command $cmd is not found."
		error_code=1
    else
		green_echo "[Passed] $cmd is found: $path"
	fi
done

packages=$(find tests -name 'test_*.ml' | sed 's/^[^_]*_//; s/\.ml$//')

for pkg in $packages ; do
	if docker run --rm $image ocamlfind query $pkg; then
		file="tests/test_$pkg.ml"
		stdout=$(cat $file | docker run -i --rm --link mysql:mysql --link postgres:postgres $image ocaml -init /home/opam/.ocamlinit)
		if echo "$stdout" | grep -i 'error\|failure\|exception\|undefined\|cannot' >/dev/null; then
			red_echo "[Failed] OPAM package $pkg"
			error_code=1
		else
			green_echo "[Passed] OPAM package $pkg"
		fi
		echo "$stdout"
	else
		green_echo "[Skipped] OPAM package $pkg is not found."
	fi
done

exit $error_code
