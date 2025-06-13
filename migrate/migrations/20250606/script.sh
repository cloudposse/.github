title "Fix go version in tests"

if [ -d "test/src" ]; then
  cd test/src
  GOTOOLCHAIN=auto go mod edit -go=1.24 -toolchain=go1.24.0
  GOTOOLCHAIN=auto go mod tidy
  GOTOOLCHAIN=auto go test -v -run Skip
  cd -

	# Merge the PR
	auto_merge
else
  echo "test/src directory not found"
fi

