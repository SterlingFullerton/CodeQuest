#!/bin/bash

# Database management script for CodeQuest
# This script helps you manage the PostgreSQL database with Docker

set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Warning: .env file not found. Using default values."
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database connection details (from environment variables with fallback defaults)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-mydb}"
DB_USER="${DB_USER:-myuser}"
DB_PASSWORD="${DB_PASSWORD:-mypassword}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to start the database
start_db() {
    print_status "Starting PostgreSQL database..."
    check_docker
    docker-compose up -d db
    print_status "Waiting for database to be ready..."
    sleep 5
    print_status "Database started successfully!"
    print_status "Connection details:"
    echo "  Host: $DB_HOST"
    echo "  Port: $DB_PORT"
    echo "  Database: $DB_NAME"
    echo "  Username: $DB_USER"
}

# Function to stop the database
stop_db() {
    print_status "Stopping PostgreSQL database..."
    docker-compose down
    print_status "Database stopped successfully!"
}

# Function to restart the database
restart_db() {
    print_status "Restarting PostgreSQL database..."
    stop_db
    start_db
}

# Function to connect to the database
connect_db() {
    print_status "Connecting to the database..."
    docker-compose exec db psql -U $DB_USER -d $DB_NAME
}

# Function to reset the database (remove all data and reinitialize)
reset_db() {
    print_warning "This will delete all data in the database!"
    read -p "Are you sure you want to continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Resetting database..."
        docker-compose down -v  # Remove volumes
        rm -rf pgdata  # Remove data directory
        docker-compose up -d db
        sleep 5
        print_status "Database reset and reinitialized successfully!"
    else
        print_status "Database reset cancelled."
    fi
}

# Function to show database status
status_db() {
    print_status "Database status:"
    docker-compose ps db
}

# Function to show logs
logs_db() {
    print_status "Database logs:"
    docker-compose logs db
}

# Function to backup database
backup_db() {
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    print_status "Creating database backup: $BACKUP_FILE"
    docker-compose exec -T db pg_dump -U $DB_USER $DB_NAME > "$BACKUP_FILE"
    print_status "Backup created successfully: $BACKUP_FILE"
}

# Function to restore database from backup
restore_db() {
    if [ -z "$1" ]; then
        print_error "Please provide backup file path"
        print_status "Usage: $0 restore <backup_file.sql>"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        print_error "Backup file not found: $1"
        exit 1
    fi
    
    print_warning "This will replace all existing data!"
    read -p "Are you sure you want to continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restoring database from: $1"
        docker-compose exec -T db psql -U $DB_USER -d $DB_NAME < "$1"
        print_status "Database restored successfully!"
    else
        print_status "Database restore cancelled."
    fi
}

# Main script logic
case "$1" in
    start)
        start_db
        ;;
    stop)
        stop_db
        ;;
    restart)
        restart_db
        ;;
    connect|psql)
        connect_db
        ;;
    reset)
        reset_db
        ;;
    status)
        status_db
        ;;
    logs)
        logs_db
        ;;
    backup)
        backup_db
        ;;
    restore)
        restore_db "$2"
        ;;
    *)
        echo "CodeQuest Database Management Script"
        echo ""
        echo "Usage: $0 {start|stop|restart|connect|reset|status|logs|backup|restore}"
        echo ""
        echo "Commands:"
        echo "  start    - Start the PostgreSQL database"
        echo "  stop     - Stop the PostgreSQL database"
        echo "  restart  - Restart the PostgreSQL database"
        echo "  connect  - Connect to the database (psql)"
        echo "  reset    - Reset database (WARNING: deletes all data)"
        echo "  status   - Show database container status"
        echo "  logs     - Show database logs"
        echo "  backup   - Create a database backup"
        echo "  restore  - Restore database from backup file"
        echo ""
        exit 1
        ;;
esac
