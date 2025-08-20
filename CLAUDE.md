# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python package that imports IMDB TSV files into a SQLite database. It downloads data from IMDB's public interface files and creates a normalized relational database with proper indices for efficient querying.

## Development Commands

### Linting and Formatting
```bash
# Check code with ruff
make lint
# or directly:
uv run ruff check imdb_sqlite/

# Format code with ruff (double quotes enforced)
make format
# or directly:
uv run ruff format imdb_sqlite/
```

### Building Distribution
```bash
make dist
# or directly:
uv build
# Creates source and wheel distributions in dist/
```

### Installing Development Dependencies
```bash
# Install with uv (recommended)
uv pip install -e ".[dev]"

# Or install individual dev tools
uv pip install ruff twine build
```

### Running the Application
```bash
# Direct execution with uv
uv run python -m imdb_sqlite

# With arguments
uv run python -m imdb_sqlite --db mydb.db --cache-dir downloads --no-index --verbose

# After local installation
uv pip install -e .
imdb-sqlite
```

### Clean Build Artifacts
```bash
make clean
```

## Architecture

The application is structured as a single-module Python package with the following key components:

### Core Components

1. **Database Class** (`imdb_sqlite/__main__.py:109-194`): SQLite database abstraction handling schema creation, table management, and index creation. Uses pragma settings for performance optimization.

2. **Column Configuration** (`imdb_sqlite/__main__.py:39-48`): Defines table column metadata including types, primary keys, indices, and constraints.

3. **TSV_TABLE_MAP** (`imdb_sqlite/__main__.py:55-106`): Central configuration mapping IMDB TSV files to database tables with column mappings. Defines 6 tables:
   - `people`: Entertainment industry professionals
   - `titles`: Movies, TV shows, episodes, etc.
   - `akas`: Alternative titles in different languages
   - `crew`: Person-to-title relationships with roles
   - `episodes`: TV show episode metadata
   - `ratings`: Title ratings and vote counts

### Data Flow

1. **Download Phase**: `ensure_downloaded()` fetches compressed TSV files from IMDB to cache directory
2. **Import Phase**: `import_file()` processes each TSV file:
   - Counts total lines for progress tracking
   - Streams data using generators for memory efficiency
   - Batch inserts with transactions for performance
3. **Index Creation**: Optional post-import index creation for query optimization
4. **Analysis**: Runs SQLite ANALYZE for query planner statistics

### Key Design Decisions

- **Streaming Processing**: Uses generators and line-by-line processing to handle multi-GB files without loading into memory
- **Transaction Management**: Wraps each file import in a transaction with rollback on failure
- **Configurable Indices**: `--no-index` flag allows skipping index creation to save ~50% disk space for ETL workflows
- **Progress Tracking**: Uses tqdm for visual progress on long-running imports

## Database Schema

The database creates foreign key relationships between tables via ID columns:
- `title_id`: Links titles, akas, crew, episodes, and ratings
- `person_id`: Links people and crew
- `show_title_id` and `episode_title_id`: Links TV shows to their episodes

Performance is optimized through selective indexing on commonly queried columns like names, titles, and foreign keys.