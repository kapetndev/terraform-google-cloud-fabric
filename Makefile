SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := check
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
TERRAFORM := terraform
MODULES := $(wildcard modules/*)

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX =

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo
	@echo "Targets:"
	@echo "  init     Initialize the Terraform working directory"
	@echo "  check    Check if the configuration is well formatted (default)"
	@echo "  format   Format the configuration"
	@echo "  validate Validate the configuration"
	@echo "  clean    Clean the Terraform working directory"

TOPTARGETS := init validate clean

$(TOPTARGETS): $(MODULES)
$(MODULES):
	@$(MAKE) -sC $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(MODULES)

.PHONY: check
check:
	$(TERRAFORM) fmt -check -recursive

.PHONY: format
format:
	$(TERRAFORM) fmt -recursive
