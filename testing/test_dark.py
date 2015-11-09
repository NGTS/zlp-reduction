import pytest
import os
from astropy.io import fits
import numpy as np


@pytest.fixture
def filename():
    return os.environ['FILENAME']


@pytest.mark.dark
def test_dark_creation(filename):
    assert os.path.isfile(filename)


@pytest.mark.dark
def test_dark_correct_dimensions(filename):
    data = fits.getdata(filename)
    assert data.shape == (2048, 2048)


@pytest.mark.dark
def test_dummy_data(filename):
    data = fits.getdata(filename)
    assert np.unique(data) == 0.
