#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = E2E-ML-TEMPLATE
PYTHON_VERSION = 3.11
PYTHON_INTERPRETER = python3

#################################################################################
# COMMANDS                                                                      #
#################################################################################


## Install Python Dependencies
.PHONY: requirements
requirements:
	$(PYTHON_INTERPRETER) -m pip install -U pip
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt
	



## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8 and black (use `make format` to do formatting)
.PHONY: lint
lint:
	flake8 project_name
	isort --check --diff --profile black project_name
	black --check --config pyproject.toml project_name

## Format source code with black
.PHONY: format
format:
	black --config pyproject.toml project_name

## Download Data from storage system
.PHONY: sync_data_down
sync_data_down:
	az storage blob download-batch -s UFUF/data/ \
		-d data/
	

## Upload Data to storage system
.PHONY: sync_data_up
sync_data_up:
	az storage blob upload-batch -d UFUF/data/ \
		-s data/


## Set up python interpreter environment
.PHONY: create_environment
create_environment:
	@bash -c "if [ ! -z `which virtualenvwrapper.sh` ]; then source `which virtualenvwrapper.sh`; mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER); else mkvirtualenv.bat $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER); fi"
	@echo ">>> New virtualenv created. Activate with:\nworkon $(PROJECT_NAME)"


## set up jupyter for code review
.PHONY: setup_jupyter
setup_jupyter:
	@echo "Installing nbautoexport..."
	nbautoexport install
	@echo "Configuring nbautoexport for the 'notebooks' directory..."
	nbautoexport configure notebooks
	@echo "Starting Jupyter Notebook..."
	jupyter notebook notebooks



#################################################################################
# PROJECT RULES                                                                 #
#################################################################################


## Make Dataset
.PHONY: data
data: requirements
	$(PYTHON_INTERPRETER) project_name/dataset.py

## Make Features
.PHONY: features
features: requirements
	$(PYTHON_INTERPRETER) project_name/features.py

## Make Plots
.PHONY: plots
plots: requirements
	$(PYTHON_INTERPRETER) project_name/plots.py

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)
