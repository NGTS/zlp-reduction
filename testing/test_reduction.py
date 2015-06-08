import glob
import pytest
import os


@pytest.fixture
def files():
    return glob.glob(os.path.join(os.getcwd(), 'output', 'proc*.fits'))


@pytest.mark.reduction
def test_files_exist(files):
    assert len(files) == 5
