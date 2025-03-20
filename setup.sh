#!/bin/bash
# setup.sh - สคริปต์สำหรับตั้งค่าโครงสร้างโปรเจคเริ่มต้น

echo "🚀 เริ่มต้นการตั้งค่าโครงสร้างโปรเจค Book Management System..."

# สร้างโครงสร้างไดเรกทอรี
mkdir -p backend frontend .devcontainer

# สร้าง .devcontainer/devcontainer.json
echo "📁 กำลังสร้าง .devcontainer/devcontainer.json..."
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
        "ms-azuretools.vscode-docker",
        "eamodio.gitlens",
        "visualstudioexptteam.vscodeintellicode",
        "streetsidesoftware.code-spell-checker",
        "njpwerner.autodocstring",
        "ms-python.isort",
        "redhat.vscode-yaml",
        "gruntfuggly.todo-tree",
        "yzhang.markdown-all-in-one"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "python.linting.flake8Enabled": true,
        "python.formatting.provider": "black",
        "python.formatting.blackArgs": ["--line-length", "88"],
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.organizeImports": "explicit"
        },
        "python.testing.pytestEnabled": true,
        "python.testing.unittestEnabled": false,
        "python.testing.nosetestsEnabled": false,
        "python.testing.pytestArgs": ["--no-cov"],
        "files.exclude": {
          "**/__pycache__": true,
          "**/.pytest_cache": true,
          "**/*.pyc": true
        },
        "terminal.integrated.defaultProfile.linux": "bash",
        "[python]": {
          "editor.rulers": [88],
          "editor.tabSize": 4
        },
        "[javascript]": {
          "editor.tabSize": 2,
          "editor.defaultFormatter": "esbenp.prettier-vscode"
        },
        "[javascriptreact]": {
          "editor.tabSize": 2,
          "editor.defaultFormatter": "esbenp.prettier-vscode"
        },
        "[json]": {
          "editor.tabSize": 2,
          "editor.defaultFormatter": "esbenp.prettier-vscode"
        },
        "editor.bracketPairColorization.enabled": true,
        "editor.guides.bracketPairs": true
      }
    }
  },
  "features": {
    "ghcr.io/devcontainers/features/git:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "lts"
    }
  },
  "forwardPorts": [8000, 3000, 5432],
  "postCreateCommand": "pip install black flake8 pylint isort pytest pytest-django && python manage.py migrate",
  "postStartCommand": "echo 'Dev container started - Happy coding!' > /dev/stderr",
  "remoteUser": "vscode",
  "shutdownAction": "stopCompose"
}
EOL

# สร้าง docker-compose.yml
echo "📁 กำลังสร้าง docker-compose.yml..."
cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  db:
    image: postgres:15-alpine
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
      - backend_venv:/app/.venv
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=bookmanagement
      - POSTGRES_HOST=db
      - DEBUG=True
      - SECRET_KEY=your-secret-key-for-development
    command: sh -c "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    volumes:
      - ./frontend:/app
      - frontend_node_modules:/app/node_modules
    ports:
      - "3000:3000"
    depends_on:
      - backend
    environment:
      - REACT_APP_API_URL=http://localhost:8000/api
    command: npm start

volumes:
  postgres_data:
  backend_venv:
  frontend_node_modules:

networks:
  default:
    name: bookmanagement-network
EOL

# สร้าง Dockerfile.dev สำหรับ Backend
echo "📁 กำลังสร้าง backend/Dockerfile.dev..."
cat > backend/Dockerfile.dev << 'EOL'
# backend/Dockerfile.dev
FROM python:3.9-slim

WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv .venv
ENV PATH="/app/.venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Create a non-root user to run the application
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/bash -m appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user for better security
USER appuser

# We'll mount the source code as a volume in docker-compose
# Don't copy the code here in development mode

# Expose the port
EXPOSE 8000

# Command will be provided by docker-compose for development
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
EOL

# สร้าง requirements.txt สำหรับ Backend
echo "📁 กำลังสร้าง backend/requirements.txt..."
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
echo "📁 กำลังสร้าง frontend/Dockerfile.dev..."
cat > frontend/Dockerfile.dev << 'EOL'
# frontend/Dockerfile.dev
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Add node_modules/.bin to PATH
ENV PATH /app/node_modules/.bin:$PATH

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm ci --quiet && \
    npm cache clean --force

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# We'll mount the source code as a volume in docker-compose
# No need to copy code in development mode

# Expose port
EXPOSE 3000

# Start development server
CMD ["npm", "start"]
EOL

# สร้าง package.json เริ่มต้นสำหรับ Frontend
echo "📁 กำลังสร้าง frontend/package.json..."
cat > frontend/package.json << 'EOL'
{
  "name": "book-management-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.6.2",
    "bootstrap": "^5.3.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-relay": "^16.0.0",
    "react-router-dom": "^6.20.0",
    "react-scripts": "5.0.1",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "lint": "eslint src/**/*.{js,jsx}",
    "format": "prettier --write src/**/*.{js,jsx,css,scss}"
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
  },
  "devDependencies": {
    "eslint": "^8.54.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-prettier": "^5.0.1",
    "eslint-plugin-react": "^7.33.2",
    "prettier": "^3.1.0"
  }
}
EOL

# สร้าง Django project เริ่มต้น
echo "📁 กำลังสร้างโครงสร้าง Django project เริ่มต้น..."
mkdir -p backend/bookmanagement
cat > backend/bookmanagement/__init__.py << 'EOL'
# Django project init
EOL

# สร้าง .gitignore
echo "📁 กำลังสร้าง .gitignore..."
cat > .gitignore << 'EOL'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
.env
.venv
env/
venv/
ENV/
.pytest_cache/

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
media/
static/

# React
node_modules/
.pnp/
.pnp.js
coverage/
build/
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDEs and editors
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace
*.sublime-workspace
.history/

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOL

# สร้าง .env files ตัวอย่าง
echo "📁 กำลังสร้างไฟล์ .env ตัวอย่าง..."
cat > backend/.env.example << 'EOL'
DEBUG=True
SECRET_KEY=your-secret-key-here
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=bookmanagement
POSTGRES_HOST=db
EOL

# เพิ่มสิทธิ์ในการเรียกใช้งานสคริปต์
chmod +x setup.sh

echo "✅ การตั้งค่าโครงสร้างโปรเจคเสร็จสมบูรณ์!"
echo "🔍 สร้างไฟล์และโฟลเดอร์ต่อไปนี้:"
echo "  - .devcontainer/devcontainer.json"
echo "  - docker-compose.yml"
echo "  - backend/Dockerfile.dev"
echo "  - backend/requirements.txt"
echo "  - frontend/Dockerfile.dev"
echo "  - frontend/package.json"
echo "  - README.md"
echo "  - .gitignore"
echo "  - backend/.env.example"
echo ""
echo "🚀 คุณสามารถเริ่มต้นโปรเจคด้วยคำสั่ง:"
echo "   code . # เปิด VS Code"
echo "   # จากนั้นกด F1 และเลือก 'Remote-Containers: Open Folder in Container'"
echo ""
echo "🌟 Happy coding! 🌟"