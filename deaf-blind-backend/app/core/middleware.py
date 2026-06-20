"""Custom Starlette/FastAPI middleware (security headers, rate limit, analytics).

Stubs — wire into main.py as needed. Mirrors CarsBackend's middleware layer.
"""
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        # TODO: add HSTS, X-Content-Type-Options, etc.
        return response
