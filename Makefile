#* Variables
PYTHON := python
PYTHONPATH := `pwd`
#* Poetry
.PHONY: poetry-download
poetry-download:
	curl -sSL https://install.python-poetry.org/ | $(PYTHON) -

.PHONY: poetry-remove
poetry-remove:
	curl -sSL https://install.python-poetry.org/ | $(PYTHON) - --uninstall

#* Installation
.PHONY: install
install:
	poetry lock -n && poetry export --without-hashes > requirements.txt
	poetry install -n
	make pre-commit-install

.PHONY: pre-commit-install
pre-commit-install:
	poetry run pre-commit install

#* Formatters
.PHONY: black
black:
	poetry run black --version
	poetry run black --config pyproject.toml magneto_pyelastica tests

.PHONY: black-check
black-check:
	poetry run black --version
	poetry run black --diff --check --config pyproject.toml magneto_pyelastica tests

.PHONY: flake8
flake8:
	poetry run flake8 --version
	poetry run flake8 magneto_pyelastica tests

.PHONY: format-codestyle
format-codestyle: black flake8

.PHONY: test
test:
	NUMBA_DISABLE_JIT=1 poetry run pytest --cov=magneto_pyelastica

.PHONY: test_ci
test_ci:
	NUMBA_DISABLE_JIT=1 poetry run pytest --cov=magneto_pyelastica --cov-report=xml

.PHONY: check-codestyle
check-codestyle: black-check flake8

.PHONY: formatting
formatting: format-codestyle

.PHONY: update-dev-deps
update-dev-deps:
	poetry add -D pytest@latest coverage@latest pytest-html@latest pytest-cov@latest black@latest

#* Cleaning
.PHONY: pycache-remove
pycache-remove:
	find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf

.PHONY: dsstore-remove
dsstore-remove:
	find . | grep -E ".DS_Store" | xargs rm -rf

.PHONY: ipynbcheckpoints-remove
ipynbcheckpoints-remove:
	find . | grep -E ".ipynb_checkpoints" | xargs rm -rf

.PHONY: pytestcache-remove
pytestcache-remove:
	find . | grep -E ".pytest_cache" | xargs rm -rf

.PHONY: build-remove
build-remove:
	rm -rf build/

.PHONY: cleanup
cleanup: pycache-remove dsstore-remove ipynbcheckpoints-remove pytestcache-remove

all: format-codestyle cleanup test

ci: check-codestyle
