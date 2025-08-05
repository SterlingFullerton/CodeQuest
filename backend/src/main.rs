use axum::{routing::get, Router, Json, extract::State};
use serde::{Serialize, Deserialize};
use tower_http::cors::CorsLayer;
use sqlx::{PgPool, FromRow};
use std::sync::Arc;

// Database models
#[derive(Debug, Serialize, Deserialize, FromRow)]
struct User {
    id: i32,
    name: String,
    email: String,
    created_at: chrono::DateTime<chrono::Utc>,
    updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
struct Project {
    id: i32,
    name: String,
    description: Option<String>,
    user_id: i32,
    created_at: chrono::DateTime<chrono::Utc>,
    updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
struct Task {
    id: i32,
    title: String,
    description: Option<String>,
    status: String,
    project_id: i32,
    assigned_user_id: Option<i32>,
    created_at: chrono::DateTime<chrono::Utc>,
    updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Serialize)]
struct Hello {
    message: String,
}

// Application state
type AppState = Arc<PgPool>;

async fn hello_handler() -> Json<Hello> {
    Json(Hello {
        message: "Hello from Rust backend!".into(),
    })
}

async fn get_users(State(pool): State<AppState>) -> Json<Vec<User>> {
    let users = sqlx::query_as::<_, User>("SELECT * FROM users ORDER BY id")
        .fetch_all(&*pool)
        .await
        .unwrap_or_else(|_| vec![]);
    
    Json(users)
}

async fn get_projects(State(pool): State<AppState>) -> Json<Vec<Project>> {
    let projects = sqlx::query_as::<_, Project>("SELECT * FROM projects ORDER BY id")
        .fetch_all(&*pool)
        .await
        .unwrap_or_else(|_| vec![]);
    
    Json(projects)
}

async fn get_tasks(State(pool): State<AppState>) -> Json<Vec<Task>> {
    let tasks = sqlx::query_as::<_, Task>("SELECT * FROM tasks ORDER BY id")
        .fetch_all(&*pool)
        .await
        .unwrap_or_else(|_| vec![]);
    
    Json(tasks)
}

#[tokio::main]
async fn main() {
    // Load environment variables
    dotenvy::dotenv().ok();
    
    // Get database URL from environment
    let database_url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set in .env file");
    
    // Create database connection pool
    let pool = PgPool::connect(&database_url)
        .await
        .expect("Failed to connect to database");
    
    println!("✅ Connected to database successfully");
    
    // Create shared state
    let app_state = Arc::new(pool);
    
    let app = Router::new()
        .route("/api/hello", get(hello_handler))
        .route("/api/users", get(get_users))
        .route("/api/projects", get(get_projects))
        .route("/api/tasks", get(get_tasks))
        .layer(CorsLayer::permissive()) // Enable CORS for frontend communication
        .with_state(app_state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3001").await.unwrap();
    println!("🚀 Server running on http://localhost:3001");
    println!("📋 Available endpoints:");
    println!("   GET /api/hello   - Hello message");
    println!("   GET /api/users   - List all users");
    println!("   GET /api/projects - List all projects");
    println!("   GET /api/tasks   - List all tasks");
    axum::serve(listener, app).await.unwrap();
}
