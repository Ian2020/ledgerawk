#!/bin/env python3

import os
import unittest
from importlib.util import spec_from_loader, module_from_spec
from importlib.machinery import SourceFileLoader


usbank_ccard = None


def import_reader():
    # Because our source does not have normal .py extension, we need a little
    # extra trickery
    # https://stackoverflow.com/a/43602645
    abspath = os.path.abspath("./src/reader_usbank_ccard")
    spec = spec_from_loader("reader_usbank_ccard",
                            SourceFileLoader("reader_usbank_ccard", abspath))
    global usbank_ccard
    usbank_ccard = module_from_spec(spec)
    spec.loader.exec_module(usbank_ccard)


class TestReader(unittest.TestCase):
    def test_upper(self):
        usbank_ccard.go("hello")
        self.assertEqual(1, 1)


if __name__ == '__main__':
    import_reader()
    unittest.main()
