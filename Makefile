SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
TERRAFORM := terraform

# Discover all module directories dynamically
MODULES := $(shell find modules -name "*.tf" -exec dirname {} \; | sort -u)

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX =

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo
	@echo "Targets:"
	@echo "  init   Initialize the Terraform working directory"
	@echo "  check  Check if the configuration is well formatted (default)"
	@echo "  format Format the configuration"
	@echo "  list   List all discovered modules"
	@echo "  test   Validate the configuration"
	@echo "  clean  Clean the Terraform working directory"
	@echo
	@echo "Parallel execution:"
	@echo "  Use -j<N> flag for parallel execution, e.g. 'make -j4 test'"

.PHONY: init
init: $(MODULES:%=%/.terraform)

.PHONY: check
check:
	@$(TERRAFORM) fmt -check -recursive
	echo "Configuration is well formatted."

.PHONY: format
format:
	@$(TERRAFORM) fmt -recursive
	echo "Configuration formatted successfully."

.PHONY: list
list:
	@printf "%s\n" $(MODULES)

.PHONY: test
test: init
	@bin/test

.PHONY: clean
clean: $(MODULES:%=%-clean)

%/.terraform:
	@echo "Initializing Terraform in $*"
	@$(TERRAFORM) -chdir=$* init -backend=false >/dev/null

.PHONY: %-test
%-test: %/.terraform
	@bin/test -m $(patsubst modules/%,%,$*) -v

.PHONY: %-clean
%-clean:
	@rm -rf $*/.terraform $*/.terraform.lock.hcl
