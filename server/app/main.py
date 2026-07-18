from fastapi import FastAPI

from app.auth.router import router as auth_router
from app.core.config import get_settings
from app.users.router import router as users_router


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title=settings.app_name,
        debug=settings.app_debug,
        version="0.1.0",
    )
    app.include_router(auth_router)
    app.include_router(users_router)

    @app.get("/health", tags=["health"])
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    return app


app = create_app()
