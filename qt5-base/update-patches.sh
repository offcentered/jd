#!/usr/bin/bash

# Copies patches from QTBASE_GIT_WORKING_DIR to default
# variant of mingw-w64-qt5-base and outputs altered source and
# md5sums arrays

set -e # abort on first error
shopt -s nullglob

dest="${PWD}/mingw-w64"
wd="${QTBASE_GIT_WORKING_DIR}"

source "$dest/PKGBUILD"

new_sources=()
new_md5sums=()
file_index=0
for source in "${source[@]}"; do
	[ "${source: -6}" != .patch ] && \
		new_sources+=("$source") \
		new_md5sums+=("${md5sums[$file_index]}")
	file_index=$((file_index + 1))
done

patches=("$dest"/*.patch)
for patch in "${patches[@]}"; do
	new_sources+=("$patch")
done

for patch in "${patches[@]}"; do
	rm "$patch"
done

pushd "$wd" > /dev/null
git checkout "${pkgver}-mingw-w64"
git format-patch "${pkgver}" --output-directory "$dest"
popd > /dev/null

new_patches=("$dest"/*.patch)
for patch in "${new_patches[@]}"; do
	new_sources+=("$patch")
	sum=$(md5sum "$patch")
	new_md5sums+=(${sum%% *})
done

echo -n "source=('${new_sources[0]}'"
for source in "${new_sources[@]:1}"; do
	echo
	echo -n "        '${source##*/}'"
done
echo ')'

echo -n "md5sums=('${new_md5sums[0]}'"
for sum in "${new_md5sums[@]:1}"; do
	echo
	echo -n "         '${sum}'"
done
echo ')'
