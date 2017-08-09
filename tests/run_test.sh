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
	path=$(type -p $cmd)
	if [[ "$path" == '' ]]; then
		red_echo "[Failed] Command $cmd is not found."
		failed_tests+="$cmd "
		exit_code=1
    else
		green_echo "[Passed] $cmd is found: $path"
	fi
done

##
## Test opam packages on Jupyter
##
kernel_name="ocaml-jupyter-$(opam config var switch)"

for nb_path in $(find "$dir" -name '*.ipynb'); do
    pkg=$(basename "$nb_path" | sed 's/\.ipynb$//')
	pkg_path=$(ocamlfind query "$pkg")
    if [[ "$pkg_path" != '' ]]; then
        yellow_echo "Testing package $pkg: $pkg_path"

        nbg_path="/tmp/$pkg.ipynb"

        sed "s/__OCAML_KERNEL__/$kernel_name/" "$nb_path" > "$nbg_path"

        if jupyter nbconvert --to notebook --execute "$nbg_path"; then
			green_echo "[Passed] OPAM package $pkg"
		else
			red_echo "[Failed] OPAM package $pkg"
			exit_code=1
			failed_tests+="$pkg "
		fi

		rm -f "$nbg_path"
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
