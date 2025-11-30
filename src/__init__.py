""" """

import logging
import sys
from importlib.metadata import version

assert sys.version_info >= (3, 0)

_LOGGER = logging.getLogger(__name__)

__version__ = version("tellsticknet")
