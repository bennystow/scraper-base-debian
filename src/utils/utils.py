# Add these functions outside the Config class
import os
import logging
from tempfile import mkdtemp
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

logger = logging.getLogger(__name__)


def is_running_in_docker():
    # Check for a common Docker environment variable
    # Also check for GITHUB_ACTIONS, which is set by GitHub Actions and the 'act' tool.
    # This makes the detection more robust for CI/CD environments.
    in_docker = os.environ.get("RUNNING_IN_DOCKER", "").lower() in ("true", "1")
    in_ci = os.environ.get("GITHUB_ACTIONS", "").lower() == "true"
    return in_docker or in_ci


def get_chrome_options(headless_override=None):
    """
    Returns Chrome options suitable for the current environment (local or Docker).
    Args:
    headless_override (bool, optional): If True, forces headless mode.
        If False, forces non-headless mode.
        If None, determines headless based on environment.
        Defaults to None.
    """
    chrome_options = Options()
    # Common options for both environments
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--log-level=3")  # Suppress console noise
    chrome_options.add_experimental_option("excludeSwitches", ["enable-logging"])  # Suppress DevTools messages
    # Determine headless mode
    run_headless = headless_override if headless_override is not None else is_running_in_docker()

    if run_headless:
        logger.info("Applying headless Chrome options.")

        chrome_options.add_argument("--headless=new")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        # --no-zygote and --single-process can lead to instability; removed for general use.
        # --disable-dev-tools is often implicit with headless and other automation flags.

        # Use a single temporary directory for user data. Chrome will manage subdirectories.
        chrome_options.add_argument(f"--user-data-dir={mkdtemp()}")
        # Removed explicit --data-path and --disk-cache-dir as they are managed within user-data-dir.
        # Removed --remote-debugging-pipe as it's not typically needed for basic automation.
        # Removed --verbose to reduce noise; can be re-added for deep debugging of Chrome.
        # chrome_options.add_argument("--log-path=/tmp/chrome_debug.log") # Optional: for Chrome's own logs
        chrome_options.binary_location = "/opt/chrome/chrome-linux64/chrome"
    else:
        logger.info("Applying non-headless Chrome options.")

    return chrome_options


def get_chrome_service(headless_override=None):
    if is_running_in_docker():
        logger.info("SERVICE - Running in Docker environment")
        return Service(
            executable_path="/opt/chrome-driver/chromedriver-linux64/chromedriver",
            service_log_path="/tmp/chromedriver.log",
        )

    else:
        logger.info("SERVICE - Running in local environment")
        return None
