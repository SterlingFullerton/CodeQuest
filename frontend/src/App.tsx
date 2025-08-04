import React, { useState, useEffect } from 'react';
import './App.css';

interface HelloResponse {
  message: string;
}

function App() {
  const [message, setMessage] = useState<string>('Loading...');
  const [error, setError] = useState<string>('');

  useEffect(() => {
    const fetchMessage = async () => {
      try {
        const response = await fetch('http://localhost:3001/api/hello');
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data: HelloResponse = await response.json();
        setMessage(data.message);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch message');
        setMessage('Failed to connect to backend');
      }
    };

    fetchMessage();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>CodeQuest</h1>
        <h2>Rust Backend + React Frontend</h2>
        <div style={{ 
          padding: '20px', 
          margin: '20px', 
          border: '2px solid #61dafb', 
          borderRadius: '10px',
          backgroundColor: '#282c34'
        }}>
          <h3>Message from Rust Backend:</h3>
          <p style={{ fontSize: '1.2em', color: '#61dafb' }}>
            {message}
          </p>
          {error && (
            <p style={{ color: '#ff6b6b', fontSize: '0.9em' }}>
              Error: {error}
            </p>
          )}
        </div>
        <p style={{ fontSize: '0.9em', color: '#888' }}>
          Make sure your Rust backend is running on port 3001
        </p>
      </header>
    </div>
  );
}

export default App;
