# Custom PostgreSQL Docker

Customization of the Docker Official Image https://hub.docker.com/_/postgres for AI projects, adds:
- **pgvector** for vector similarity search
- **Apache AGE** for graph database functionality

**Note:** At the moment, the AGE extension isn't compatible with PostgreSQL 18.

## Features

- **PostgreSQL 17** - Latest stable version
- **pgvector** - Vector similarity search capabilities
- **Apache AGE** - Graph database extension
- **Docker Compose** - Easy orchestration and management
- **Persistent data** - Configurable data persistence
- **Automated setup** - Convenient scripts for management

## Prerequisites

- Docker
- Docker Compose
- bash (for setup scripts)

## Quick Start

### 1. Create Environment Configuration

Create a `.env` file in the project root with your configuration:

```bash
# Container configuration
CONTAINER_NAME=custom-postgres
POSTGRES_PORT=5432

# Database credentials
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=mydatabase

# Data persistence path (absolute or relative)
POSTGRES_DATA_PATH=~/.docker_volumes/postgres
```

### 2. Run Setup

```bash
./scripts/setup.sh
```

This script will:
- Validate your environment configuration
- Create necessary directories
- Build the custom PostgreSQL Docker image
- Start the container with extensions enabled

## Usage

### Starting and Stopping

```bash
# Start the PostgreSQL container
./scripts/setup.sh

# Stop the container
docker-compose down

# Stop and remove all data/containers/images
./scripts/cleanup.sh
```

### Connecting to the Database

Connect using your configured credentials:
- **Host:** `localhost`
- **Port:** `5432` (or your configured `POSTGRES_PORT`)
- **Database:** Your configured `POSTGRES_DB`
- **Username:** Your configured `POSTGRES_USER`
- **Password:** Your configured `POSTGRES_PASSWORD`

Example connection string:
```
postgresql://postgres:postgres@localhost:5432/mydatabase
```

### Using Extensions

Both extensions are automatically installed and available:

#### pgvector Usage
```sql
-- Create a table with vector column
CREATE TABLE embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding VECTOR(1536)
);

-- Insert vector data
INSERT INTO embeddings (content, embedding) 
VALUES ('sample text', '[1,2,3,...]');

-- Perform similarity search
SELECT content, embedding <-> '[1,2,3,...]' as distance 
FROM embeddings 
ORDER BY distance;
```

#### Apache AGE Usage
```sql
-- Load the AGE extension
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Create a graph
SELECT create_graph('demo_graph');

-- Create nodes and edges
SELECT * FROM cypher('demo_graph', $$
  CREATE (a:Person {name: 'Alice', age: 30})
  RETURN a
$$) as (a agtype);
```

## Project Structure

```
.
├── docker-compose.yml          # Docker Compose configuration
├── README.md                   # This file
├── .env                        # Environment variables (create from example above)
├── docker/
│   ├── Dockerfile             # PostgreSQL + extensions build
│   └── init-scripts/
│       └── 01-setup-extensions.sql  # Extension initialization
└── scripts/
    ├── setup.sh              # Setup and start script
    └── cleanup.sh            # Cleanup script
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CONTAINER_NAME` | Docker container name | `custom-postgres` |
| `POSTGRES_PORT` | Host port for PostgreSQL | `5432` |
| `POSTGRES_USER` | Database username | `postgres` |
| `POSTGRES_PASSWORD` | Database password | `postgres` |
| `POSTGRES_DB` | Database name | `mydatabase` |
| `POSTGRES_DATA_PATH` | Data persistence path | `~/.docker_volumes/postgres` |

### Data Persistence

The PostgreSQL data is persisted in the directory specified by `POSTGRES_DATA_PATH`. This ensures your data survives container restarts and rebuilds.

## Extensions Included

### pgvector
- **Version:** Latest from master branch
- **Purpose:** Vector similarity search and operations
- **Documentation:** [pgvector GitHub](https://github.com/pgvector/pgvector)

### Apache AGE
- **Version:** 1.6.0 for PostgreSQL 17
- **Purpose:** Graph database functionality with Cypher query language
- **Documentation:** [Apache AGE](https://age.apache.org/)

## Troubleshooting

### Permission Issues
If you encounter permission issues with the data directory:
```bash
sudo chown -R $(whoami) ~/.docker_volumes/postgres
# Or for your specific POSTGRES_DATA_PATH:
sudo chown -R $(whoami) $POSTGRES_DATA_PATH
```

### Container Won't Start
Check the logs:
```bash
docker-compose logs postgres
```

### Extensions Not Available
Verify extensions are installed:
```sql
SELECT * FROM pg_available_extensions WHERE name IN ('vector', 'age');
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to improve this Docker setup.

## License

This project is open source. The extensions (pgvector and Apache AGE) have their own respective licenses.