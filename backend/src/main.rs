use axum::{routing::get, Router, Json};
use serde::Serialize;
use tower_http::cors::CorsLayer;

#[derive(Serialize)]
struct Hello {
    message: String,
}

async fn hello_handler() -> Json<Hello> {
    Json(Hello {
        message: "Hello from Rust backend!".into(),
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/api/hello", get(hello_handler))
        .layer(CorsLayer::permissive()); // Enable CORS for frontend communication

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3001").await.unwrap();
    println!("🚀 Server running on http://localhost:3001");
    axum::serve(listener, app).await.unwrap();
}
