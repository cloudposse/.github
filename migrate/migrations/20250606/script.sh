title "Fix go version in tests"

cd test/src
GOTOOLCHAIN=auto go mod edit -go=1.23 -toolchain=go1.23.0
GOTOOLCHAIN=auto go mod tidy
GOTOOLCHAIN=auto go test -v -run Skip		
cd -

# Merge the PR
auto_merge
