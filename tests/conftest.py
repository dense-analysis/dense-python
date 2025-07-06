import socket
from typing import Any, Never

import pytest


@pytest.fixture(autouse=True)
def no_network(request: Any):
    """
    Disables all outgoing network connections by monkey-patching functions.

    `@pytest.mark.allow_network` can be set on test to allow network access.

    This fixture prevents tests from accidentally running network requests
    which can be a security issue and make tests run slower.
    """
    if request.node.get_closest_marker('allow_network'):
        yield
        return

    _orig_socket = socket.socket
    _orig_create_connection = socket.create_connection

    class NoNetworkSocket(_orig_socket):
        def connect(self, *args: Any, **kwargs: Any) -> Never:
            raise RuntimeError(
                'Network disabled: use @pytest.mark.allow_network',
            )

    def _no_network_create(*args: Any, **kwargs: Any) -> Never:
        raise RuntimeError(
            'Network disabled: use @pytest.mark.allow_network',
        )

    socket.socket = NoNetworkSocket
    socket.create_connection = _no_network_create

    try:
        yield
    finally:
        socket.socket = _orig_socket
        socket.create_connection = _orig_create_connection
