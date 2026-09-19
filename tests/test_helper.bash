# tests/test_helper.bash - shared bootstrap for the Ghostline bats suite.
GHOSTLINE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
export GHOSTLINE_ROOT
export TERM="${TERM:-xterm}"

load_libs() {
    # shellcheck source=../lib/core.sh
    source "${GHOSTLINE_ROOT}/lib/core.sh"
    # shellcheck source=../lib/installer.sh
    source "${GHOSTLINE_ROOT}/lib/installer.sh"
}
