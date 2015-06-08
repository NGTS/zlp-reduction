import pytest
import os
from astropy.io import fits


@pytest.fixture
def filename():
    return os.environ['FILENAME']


@pytest.mark.bias
def test_bias_creation(filename):
    assert os.path.isfile(filename)


@pytest.mark.bias
def test_bias_correct_dimensions(filename):
    data = fits.getdata(filename)
    assert data.shape == (2048, 2048)
