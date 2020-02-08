#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
script_abspath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cpus="$( nproc )"
cpu_pct="${GCCGO_BUILD_CPU_PCT:-50}"
cpu_share="$(( 1 + (cpus-1)*cpu_pct/100 ))"
cpuset_arg=()
if [[ "$cpus" != "$cpu_share" ]]; then
    cpuset_arg=( --cpuset-cpus "0-$cpu_share" )
fi

randhex() {
    printf "%x" $RANDOM
}

cmd-build-ver() {
    log="/tmp/gccgo-build-$(date +%s)-$(randhex)$(randhex).log"

    echo "Logging stdout to $log"
    start="$( date +%s )"
    pushd "$script_abspath" >> /dev/null
        docker build "${cpuset_arg[@]}" -t gccgo . > "$log"
    popd >> /dev/null

    end="$( date +%s )"
    taken=$((end-start))
    echo "Build completed in $taken seconds"
}

cmd-build-git() {
    log="/tmp/gccgo-build-$(date +%s)-$(randhex)$(randhex).log"

    echo "Logging stdout to $log"
    start="$( date +%s )"
    pushd "$script_abspath" >> /dev/null
        docker build "${cpuset_arg[@]}" -f Dockerfile.git -t gccgo-git . > "$log"
    popd >> /dev/null

    end="$( date +%s )"
    taken=$((end-start))
    echo "Build completed in $taken seconds"
}

"cmd-$1" "${@:2}"

