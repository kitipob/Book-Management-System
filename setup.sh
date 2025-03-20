#!/bin/bash
# setup.sh - สคริปต์สำหรับตั้งค่าโครงสร้างโปรเจคเริ่มต้น

# สร้างโครงสร้างไดเรกทอรี
mkdir -p backend frontend .devcontainer

# สร้าง .devcontainer/devcontainer.json
cat > .devcontainer/devcontainer.json << 'EOL'
{
  "name": "Book Management System Development",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "backend",
  "workspaceFolder": "/app",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "batisteo.vscode-django",
        "formulahendry.auto-close-tag",
        "formulahendry.auto-rename-tag",
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "ms-azuretools.vscode-docker"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "python.formatting.provider": "black",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.organizeImports": true
        }
      }
    }
  },
  "forwardPorts": [8000, 3000, 5432],
  "postCreateCommand": "pip install black pylint && python manage.py migrate",
  "remoteUser": "root"
}
EOL

# สร้าง docker-compose.yml
cat > docker-compose.yml << 'EOL'
version: '3'

services:
  db:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=bookmanagement
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: 
      context: ./backend
      dockerfile: Dockerfile.dev
    volumes:
      - ./backend:/app
      - /app/.venv
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/bookmanagement
      - DEBUG=True
      - SECRET_KEY=your-secret-key-for-development
    command: sh -c "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"

  frontend:
    build: 
      context: ./frontend
      dockerfile: Dockerfile.dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    depends_on:
      - backend
    environment:
      - REACT_APP_API_URL=http://localhost:8000/api
    command: npm start

volumes:
  postgres_data:
EOL

# สร้าง Dockerfile.dev สำหรับ Backend
cat > backend/Dockerfile.dev << 'EOL'
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install development tools
RUN pip install --no-cache-dir black pylint pytest

# Keep the container running
CMD ["bash", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
EOL

# สร้าง requirements.txt สำหรับ Backend
cat > backend/requirements.txt << 'EOL'
Django==5.1.7
djangorestframework>=3.14.0,<4.0.0
django-cors-headers>=4.3.0,<5.0.0
graphene-django>=3.0.0,<4.0.0
djangorestframework-simplejwt>=5.3.0,<6.0.0
psycopg2-binary>=2.9.9,<3.0.0
django-extensions>=3.2.0,<4.0.0
EOL

# สร้าง Dockerfile.dev สำหรับ Frontend
cat > frontend/Dockerfile.dev << 'EOL'
FROM node:16-alpine

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Install global dev tools
RUN npm install -g eslint prettier

# Keep the container running
CMD ["npm", "start"]
EOL

# สร้าง package.json เริ่มต้นสำหรับ Frontend
cat > frontend/package.json << 'EOL'
{
  "name": "book-management-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.3.4",
    "bootstrap": "^5.2.3",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-relay": "^14.1.0",
    "react-router-dom": "^6.8.2",
    "react-scripts": "5.0.1",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOL

echo "ตั้งค่าโครงสร้างโปรเจคเสร็จสมบูรณ์!"
echo "คุณสามารถเริ่มต้นใช้งานด้วย VS Code และ Remote Containers ได้ทันที"