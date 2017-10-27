#!/bin/bash -eu

function red_echo() {
    echo -e "\033[31m$@\033[0m"
}

function green_echo() {
    echo -e "\033[32m$@\033[0m"
}

function yellow_echo() {
    echo -e "\033[33m$@\033[0m"
}

dir=$(dirname $0)
exit_code=0
failed_tests=''

##
## Test CUI commands
##
for cmd in convert ffmpeg ssh ; do
	if type $cmd >/dev/null 2>&1; then
		green_echo "[Passed] $cmd is found: $(type -p $cmd)"
    else
		red_echo "[Failed] Command $cmd is not found."
		failed_tests+="$cmd "
		exit_code=1
	fi
done

phantomjs tests/webpage.js

##
## Test opam packages on Jupyter
##
sudo chown opam:opam -R $PWD

packages=(
	lacaml
	slap
	gsl
	owl
	lbfgs
	libsvm
	ocephes
	tensorflow
	plplot
	mysql
	mariadb
	postgresql
	sqlite3
	cohttp-lwt-unix
	cohttp-async
)
for pkg in ${packages[@]}; do
	if ocamlfind query $pkg >/dev/null 2>&1; then
		yellow_echo "Testing package $pkg: $(ocamlfind query $pkg)"

		if ocaml tests/nbtest.ml "tests/$pkg.ml"; then
			green_echo "[Passed] OPAM package $pkg"
		else
			red_echo "[Failed] OPAM package $pkg"
			failed_tests+="$pkg "
			exit_code=1
		fi
	else
		green_echo "[Skipped] OPAM package $pkg is not found."
 	fi
done

if [[ "$exit_code" -eq 0 ]]; then
	green_echo 'All tests are passed.'
else
	red_echo "Some tests are failed: $failed_tests"
fi

exit $exit_code
