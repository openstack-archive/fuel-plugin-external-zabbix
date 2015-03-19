import sys
import logging

LOGGING_LEVELS = {
    'CRITICAL': logging.CRITICAL,
    'WARNING': logging.WARNING,
    'INFO': logging.INFO,
    'DEBUG': logging.DEBUG
}


def get_logger(level):
    logger = logging.getLogger()
    ch = logging.StreamHandler(sys.stdout)
    logger.setLevel(LOGGING_LEVELS[level])
    logger.addHandler(ch)
    return logger
