.PHONY: lint format test dist clean install dev-install

# Development tools
lint:
	uv run ruff check imdb_sqlite/

format:
	uv run ruff format imdb_sqlite/

test: lint
	# Add test command here when tests are available

# Build and distribution
dist: clean
	uv build

# Installation
install:
	uv pip install -e .

dev-install:
	uv pip install -e ".[dev]"

# Deployment
rc-deploy:
	uv run twine upload -r pypitest dist/*

rc-install:
	uv pip install --index-url https://test.pypi.org/simple/ imdb-sqlite

# Cleanup
clean:
	rm -rf build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
