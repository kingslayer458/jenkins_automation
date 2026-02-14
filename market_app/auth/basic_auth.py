from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
import secrets

security = HTTPBasic()

USERS_DB = {
    "admin": "admin123",
    "seller1": "sell@pass",
    "buyer1": "buy@pass",
}


def authenticate(credentials: HTTPBasicCredentials = Depends(security)) -> str:
    password = USERS_DB.get(credentials.username)
    if password is None or not secrets.compare_digest(
        credentials.password.encode(), password.encode()
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username
