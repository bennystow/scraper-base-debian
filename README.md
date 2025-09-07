# Scraper Base Debian

This is a base project for a web scraper running on Debian.

## Getting Started

### Prerequisites

- Python 3.12 or later
- Docker

### Installation

1.  Clone the repository:

    ```bash
    git clone <repository-url>
    cd scraper-base-debian
    ```

2.  Create a virtual environment and activate it:

    ```bash
    python -m venv .venv
    source .venv/bin/activate  # On Windows, use `.venv\Scripts\activate`
    ```

3.  Install the dependencies:
    ```bash
    pip install -e .
    ```

### Running the Scraper

```bash
python -m src.main
```

### Building and Running with Docker

1.  Build the Docker image:

    ```bash
    docker build -t scraper-base-debian .
    ```

2.  Run the Docker container:
    ```bash
    docker run scraper-base-debian
    ```
