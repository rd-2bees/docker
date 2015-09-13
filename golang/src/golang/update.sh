#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )


travisEnv=
googleSource=$(curl -fsSL 'https://golang.org/dl/')
for version in "${versions[@]}"; do
	# This is kinda gross, but 1.5+ versions install from the binary package
	# while 1.4 installs from src
	if [ "$version" = '1.4' ]; then
		package='src'
	else
		package='linux-amd64'
	fi

	# First check for full version from GitHub as a canonical source
	fullVersion="$(curl -fsSL "https://raw.githubusercontent.com/golang/go/release-branch.go$version/VERSION" 2>/dev/null || true)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find version from GitHub for $version, scraping golang download page"
		fullVersion="$(echo $googleSource | grep -Po '">go'"$version"'.*?\.'"$package"'\.tar\.gz</a>' | sed -r 's!.*go([^"/<]+)\.'"$package"'\.tar\.gz.*!\1!' | sort -V | tail -1)"
	fi
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find full version for $version"
		continue
	fi
	fullVersion="${fullVersion#go}" # strip "go" off "go1.4.2"
	versionTag="$fullVersion"

	# Try and fetch the SHA1 checksum from the golang source page
	checksum="$(echo $googleSource | grep -Po '">go'"$fullVersion"'\.'"$package"'\.tar\.gz</a>.*?>[a-f0-9]{40}<' | sed -r 's!.*([a-f0-9]{40}).*!\1!' | tail -1)"
	if [ -z "$checksum" ]; then
		echo >&2 "warning: cannot find checksum for $fullVersion"
		continue
	fi

	[[ "$versionTag" == *.*[^0-9]* ]] || versionTag+='.0'
	(
		set -x
		sed -ri 's/^(ENV GOLANG_VERSION) .*/\1 '"$fullVersion"'/' "$version/Dockerfile"
		sed -ri 's/^(ENV GOLANG_DOWNLOAD_SHA1) .*/\1 '"$checksum"'/' "$version/Dockerfile"
		sed -ri 's/^(FROM golang):.*/\1:'"$version"'/' "$version/"*"/Dockerfile"
		cp go-wrapper "$version/"
	)
	for variant in wheezy; do
		if [ -d "$version/$variant" ]; then
			(
				set -x
				cp "$version/Dockerfile" "$version/go-wrapper" "$version/$variant/"
				sed -i 's/^FROM .*/FROM buildpack-deps:'"$variant"'-scm/' "$version/$variant/Dockerfile"
			)
			travisEnv='\n  - VERSION='"$version VARIANT=$variant$travisEnv"
		fi
	done
	travisEnv='\n  - VERSION='"$version VARIANT=$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
