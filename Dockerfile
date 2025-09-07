# Fedora-based
FROM fedora:40
RUN dnf install -y python3 python3-pip

WORKDIR /var/task

# Install chrome dependencies
RUN dnf install -y atk cups-libs gtk3 libXcomposite alsa-lib \
    libXcursor libXdamage libXext libXi libXrandr libXScrnSaver \
    libXtst pango at-spi2-atk libXt xorg-x11-server-Xvfb \
    xorg-x11-xauth dbus-glib dbus-glib-devel nss mesa-libgbm jq unzip
COPY ./chrome-installer.sh ./chrome-installer.sh
RUN chmod +x ./chrome-installer.sh && ./chrome-installer.sh && rm ./chrome-installer.sh

# This will install dependencies into the Python environment where Lambda can find it.
COPY pyproject.toml .

RUN pip install --no-cache-dir .

ENV RUNNING_IN_DOCKER=true

# Copy the src directory from the build context into the container at /var/task/src
# COPY src/ ./src/
COPY src/ ./src/

# Command to run the application
CMD ["python3", "-m", "src.main"]
