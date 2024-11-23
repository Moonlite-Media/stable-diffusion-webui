import base64
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response
from fastapi import FastAPI
import logging

logger = logging.getLogger(__name__)
class BasicAuthMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, username: str, password: str):
        super().__init__(app)
        self.username = username
        self.password = password

    async def dispatch(self, request, call_next):

        # Allow unauthenticated access to the `/sdapi/v1/status` endpoint
        if request.url.path == "/sdapi/v1/status":
            return await call_next(request)
        
        # Extract the Authorization header
        auth_header = request.headers.get("Authorization") or request.headers.get("authorization")
        if not auth_header or not auth_header.startswith("Basic "):
            return self._unauthorized_response()

        try:
            # Decode and split the credentials
            encoded_credentials = auth_header.split(" ")[1]
            # We should add a step to santize the input here
            decoded_credentials = base64.b64decode(encoded_credentials).decode("utf-8")
            provided_username, provided_password = decoded_credentials.split(":")

            # Check credentials
            if provided_username == self.username and provided_password == self.password:
                response = await call_next(request)
                return response
            else:
                return self._unauthorized_response()
        except Exception:
            return self._unauthorized_response()

    def _unauthorized_response(self):
        return Response(
            content="Unauthorized",
            status_code=401,
            headers={"WWW-Authenticate": "Basic realm='api'"}
        )
