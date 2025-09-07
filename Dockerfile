# Debian-based
FROM debian:13-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    # Install chrome dependencies
    libatk1.0-0 \
    libcups2 \
    libgtk-3-0 \
    libxcomposite1 \
    libasound2 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxi6 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    libpango-1.0-0 \
    libatk-bridge2.0-0 \
    libxt6 \
    xvfb \
    xauth \
    libdbus-glib-1-2 \
    libnss3 \
    libgbm1 \
    jq \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/task

# Install latest stable Chrome for Testing and ChromeDriver
RUN set -eux; \
    JSON_DATA=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json) && \
    CHROME_URL=$(echo "$JSON_DATA" | jq -r '.channels.Stable.downloads.chrome[] | select(.platform=="linux64") | .url') && \
    CHROMEDRIVER_URL=$(echo "$JSON_DATA" | jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform=="linux64") | .url') && \
    \
    curl -Lo /tmp/chrome.zip "$CHROME_URL" && \
    unzip -q /tmp/chrome.zip -d /opt/ && mv /opt/chrome-linux64 /opt/chrome && \
    curl -Lo /tmp/chromedriver.zip "$CHROMEDRIVER_URL" && \
    unzip -q /tmp/chromedriver.zip -d /opt/ && mv /opt/chromedriver-linux64 /opt/chromedriver && \
    rm /tmp/chrome.zip /tmp/chromedriver.zip && \
    # Make chromedriver executable and create a symlink to a standard location.
    # This makes the setup more robust for Selenium.
    chmod +x /opt/chromedriver/chromedriver && \
    ln -s /opt/chrome/chrome /usr/bin/google-chrome

# Create a virtual environment and add it, along with Chrome, to the PATH.
# This is the recommended way to install packages with pip on modern Debian/Ubuntu.
ENV VENV_PATH=/opt/venv
RUN python3 -m venv $VENV_PATH
ENV PATH="$VENV_PATH/bin:/opt/chrome:/opt/chromedriver:$PATH"

# This will install dependencies into the Python environment where Lambda can find it.
COPY pyproject.toml .

# The pip install command now runs within the activated virtual environment.
RUN pip install --no-cache-dir .

ENV RUNNING_IN_DOCKER=true

# Copy the src directory from the build context into the container at /var/task/src
COPY src/ ./src/

# Command to run the application
CMD ["python3", "-m", "src.main"]
