-- Database initialization script for CodeQuest
-- This script will be executed when the PostgreSQL container starts for the first time

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create projects table (example for a CodeQuest app)
CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create tasks table (example for project management)
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
    assigned_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO users (name, email) VALUES 
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Alice Johnson', 'alice@example.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO projects (name, description, user_id) VALUES 
    ('CodeQuest Backend', 'Rust backend API development', 1),
    ('CodeQuest Frontend', 'React frontend development', 1),
    ('Database Design', 'PostgreSQL database schema and optimization', 2)
ON CONFLICT DO NOTHING;

INSERT INTO tasks (title, description, status, project_id, assigned_user_id) VALUES 
    ('Set up Axum server', 'Create basic REST API with Axum framework', 'completed', 1, 1),
    ('Implement CORS', 'Add CORS middleware for frontend communication', 'completed', 1, 1),
    ('Create React app', 'Set up React TypeScript frontend', 'completed', 2, 1),
    ('Connect to backend', 'Fetch data from Rust API in React', 'in_progress', 2, 1),
    ('Database integration', 'Connect Rust backend to PostgreSQL', 'pending', 1, 2),
    ('User authentication', 'Implement JWT-based authentication', 'pending', 1, 2)
ON CONFLICT DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON projects(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_user_id ON tasks(assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update the updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions (optional, depending on your setup)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myuser;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO myuser;

-- Display completion message
\echo 'Database initialization completed successfully!'
\echo 'Tables created: users, projects, tasks'
\echo 'Sample data inserted'
