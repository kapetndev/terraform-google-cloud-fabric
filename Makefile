SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MODULE_DIR ?= modules
TERRAFORM := terraform
TFTEST ?= tftest

# Discover all module directories dynamically
MODULES := $(shell find $(MODULE_DIR) -type d -name ".terraform" -prune -o -name "*.tf" -exec dirname {} \; | sort -u)

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
	@echo "  format Format the configuration"
	@echo "  test   Validate the configuration"
	@echo "  clean  Clean the Terraform working directory"
	@echo
	@echo "Parallel execution:"
	@echo "  Use -j<N> flag for parallel execution, e.g. 'make -j4 test'"

.PHONY: init
init: $(MODULES:%=%/.terraform)

.PHONY: format
format:
	@$(TERRAFORM) fmt -recursive
	echo "Configuration formatted successfully."

.PHONY: test
test:
	@$(TFTEST) --recursive --skip-lint $(MODULE_DIR)

.PHONY: clean
clean: $(MODULES:%=%-clean)

%/.terraform:
	@echo "Initializing Terraform in $*"
	@$(TERRAFORM) -chdir=$* init -backend=false >/dev/null

.PHONY: %-clean
%-clean:
	@rm -rf $*/.terraform $*/.terraform.lock.hcl
