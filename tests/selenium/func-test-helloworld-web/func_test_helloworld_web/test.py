# Copyright (C) 2021 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <nemonik@nemonik.com>

""" helloworld-web selenium test """

import logging
import unittest
import os
import socket
import time
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


class HelloworldWebTest(unittest.TestCase):
    """helloworld-web selenium test"""

    def setUp(self):
        """Executed each time a test runs to setup the browser session"""

        selenium_executor_url = (
            "http://" + SELENIUM_HOST + ":" + SELENIUM_PORT + "/wd/hub"
        )

        # Wait til container starts with browser
        while True:
            try:
                print("Trying to connect to %s" % (selenium_executor_url))
                selenium_socket = socket.socket()
                selenium_socket.connect((SELENIUM_HOST, int(SELENIUM_PORT)))
                print("Connected.")
                break
            except Exception as exception:
                print("Failed to connect. Exception is %s" % (exception))
                time.sleep(5)
            finally:
                selenium_socket.close()

        self.browser = webdriver.Remote(
            command_executor=selenium_executor_url,
            desired_capabilities=DesiredCapabilities.CHROME,
        )
        self.browser.set_window_size(1928, 1288)
        self.addCleanup(self.browser.quit)

    def test_a_helloworld_web(self):
        """Tests for `Hello world!` to be returned."""

        self.browser.get(HELLOWORLD_WEB_URL)

        assert "Hello world!" in self.browser.page_source


if __name__ == "__main__":

    try:
        SELENIUM_HOST = os.environ["SELENIUM_HOST"]

        logging.info("SELENIUM_HOST=%s" % SELENIUM_HOST)
    except:
        raise Exception("SELENIUM_HOST environment variable not set.")

    try:
        SELENIUM_PORT = os.environ["SELENIUM_PORT"]

        logging.info("SELENIUM_PORT=%s" % SELENIUM_PORT)
    except:
        raise exception("SELENIUM_PORT environment variable not set.")

    try:
        HELLOWORLD_WEB_URL = os.environ["HELLOWORLD_WEB_URL"]

        logging.info("HELLOWORLD_WEB_URL=%s" % HELLOWORLD_WEB_URL)
    except:
        raise exception("HELLOWORLD_WEB_URL environment variable not set.")

    # So that tests are fire in the order declared as the delete project is dependent on the
    # create project test
    unittest.TestLoader.sortTestMethodsUsing = None

    unittest.main(
        warnings="ignore",  # This removes socket warnings from being displayed
        failfast=True,  # Since subsequent tests aere required to have passed
        verbosity=2,  # See verbose output.  see: https://docs.python.org/2/library/unittest.html
    )
