import pytest

from server import *


@pytest.fixture()
def client():
    return app.test_client()


def test_response(client):
    response = client.get('/')
    assert response.data == b"<p>Hello, World!</p>"
