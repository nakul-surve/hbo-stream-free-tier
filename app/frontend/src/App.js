import React, { useState, useEffect } from 'react';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

function App() {
  const [videos, setVideos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('All');

  useEffect(() => {
    fetchVideos();
  }, []);

  const fetchVideos = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_URL}/api/videos`);
      if (!response.ok) throw new Error('Failed to fetch videos');
      const data = await response.json();
      setVideos(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const seedDatabase = async () => {
    try {
      const response = await fetch(`${API_URL}/api/seed`, { method: 'POST' });
      if (response.ok) {
        alert('Database seeded successfully!');
        fetchVideos();
      }
    } catch (err) {
      alert('Failed to seed database');
    }
  };

  const categories = ['All', ...new Set(videos.map(v => v.category))];

  const filteredVideos = selectedCategory === 'All' 
    ? videos 
    : videos.filter(v => v.category === selectedCategory);

  return (
    <div className="App">
      {/* Header */}
      <header className="header">
        <div className="logo">HBO STREAM</div>
        <nav className="nav">
          <button onClick={seedDatabase} className="seed-btn">Seed Data</button>
        </nav>
      </header>

      {/* Hero Section */}
      <section className="hero">
        <div className="hero-content">
          <h1>Unlimited entertainment.</h1>
          <p>Stream exclusive HBO originals, movies, and more.</p>
          <button className="cta-button">Start Watching</button>
        </div>
      </section>

      {/* Categories */}
      <div className="categories">
        {categories.map(cat => (
          <button
            key={cat}
            className={`category-btn ${selectedCategory === cat ? 'active' : ''}`}
            onClick={() => setSelectedCategory(cat)}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Video Grid */}
      <main className="content">
        <h2>Popular on HBO</h2>
        
        {loading && <div className="loading">Loading...</div>}
        {error && <div className="error">Error: {error}</div>}
        
        {!loading && filteredVideos.length === 0 && (
          <div className="empty-state">
            <p>No videos found. Click "Seed Data" to add sample content.</p>
          </div>
        )}

        <div className="video-grid">
          {filteredVideos.map(video => (
            <div key={video.id} className="video-card">
              <div className="thumbnail">
                <img 
                  src={video.thumbnail_url || 'https://via.placeholder.com/400x225/000000/FFFFFF?text=HBO'} 
                  alt={video.title}
                />
                <div className="play-overlay">▶</div>
              </div>
              <div className="video-info">
                <h3>{video.title}</h3>
                <p className="description">{video.description}</p>
                <div className="meta">
                  <span className="category">{video.category}</span>
                  {video.duration && (
                    <span className="duration">
                      {Math.floor(video.duration / 60)} min
                    </span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>

      {/* Footer */}
      <footer className="footer">
        <p>&copy; 2026 HBO Stream. Built with AWS, Terraform & Docker.</p>
        <p className="tech-stack">
          EC2 • RDS • S3 • CloudFront • FastAPI • React • PostgreSQL
        </p>
      </footer>
    </div>
  );
}

export default App;
