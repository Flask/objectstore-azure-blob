# Copyright 2026 The Agent Substrate Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The toolchain's own gofmt, not whichever one is first on PATH.
GOFMT := $(shell go env GOROOT)/bin/gofmt

# Go files git tracks or would track. Unlike `gofmt .`, this skips the gitignored
# local directories (__*, .worktrees/), as `go vet ./...` does. wildcard drops
# tracked files deleted from the working tree.
GO_FILES = $(wildcard $(shell git ls-files --cached --others --exclude-standard '*.go'))
# gofmt reads stdin when given no files, so refuse to run without a file list.
require-go-files = $(if $(GO_FILES),,$(error no Go files found by git ls-files; run from a git checkout))

.PHONY: all
all: verify test

.PHONY: build
build:
	go build ./...

.PHONY: test
test:
	go test -race ./...

.PHONY: fmt
fmt:
	$(require-go-files)
	$(GOFMT) -w $(GO_FILES)

.PHONY: verify
verify:
	$(require-go-files)
	@out="$$($(GOFMT) -l $(GO_FILES))"; if [ -n "$$out" ]; then echo "gofmt needed on:"; echo "$$out"; exit 1; fi
	go vet ./...
	go vet -tags=integration ./...
	go mod tidy -diff
