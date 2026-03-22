from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional
import os

# Environment variables
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@localhost/dbname")
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")

# Database setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Models
class Video(Base):
    __tablename__ = "videos"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    thumbnail_url = Column(String(500))
    video_url = Column(String(500))
    duration = Column(Integer)  # in seconds
    category = Column(String(100))
    created_at = Column(DateTime, default=datetime.utcnow)

# Pydantic schemas
class VideoBase(BaseModel):
    title: str
    description: Optional[str] = None
    thumbnail_url: Optional[str] = None
    video_url: Optional[str] = None
    duration: Optional[int] = None
    category: Optional[str] = "General"

class VideoCreate(VideoBase):
    pass

class VideoResponse(VideoBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# Create tables
Base.metadata.create_all(bind=engine)

# FastAPI app
app = FastAPI(
    title="HBO Stream API",
    description="Backend API for HBO-Stream platform",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Routes
@app.get("/")
async def root():
    return {
        "message": "HBO Stream API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint for load balancer"""
    try:
        # Test database connection
        db = SessionLocal()
        from sqlalchemy import text
db.execute(text("SELECT 1"))
        db.close()
        return {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database connection failed: {str(e)}")

@app.get("/api/videos", response_model=List[VideoResponse])
async def get_videos(
    skip: int = 0,
    limit: int = 20,
    category: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all videos with optional filtering"""
    query = db.query(Video)
    
    if category:
        query = query.filter(Video.category == category)
    
    videos = query.offset(skip).limit(limit).all()
    return videos

@app.get("/api/videos/{video_id}", response_model=VideoResponse)
async def get_video(video_id: int, db: Session = Depends(get_db)):
    """Get a specific video by ID"""
    video = db.query(Video).filter(Video.id == video_id).first()
    if not video:
        raise HTTPException(status_code=404, detail="Video not found")
    return video

@app.post("/api/videos", response_model=VideoResponse, status_code=201)
async def create_video(video: VideoCreate, db: Session = Depends(get_db)):
    """Create a new video entry"""
    db_video = Video(**video.dict())
    db.add(db_video)
    db.commit()
    db.refresh(db_video)
    return db_video

@app.get("/api/categories")
async def get_categories(db: Session = Depends(get_db)):
    """Get all video categories"""
    categories = db.query(Video.category).distinct().all()
    return {"categories": [cat[0] for cat in categories if cat[0]]}

# Seed data endpoint (for testing)
@app.post("/api/seed")
async def seed_data(db: Session = Depends(get_db)):
    """Seed database with sample HBO-themed content"""
    sample_videos = [
        {
            "title": "Game of Thrones: Season 1 Trailer",
            "description": "Epic fantasy series - Winter is Coming",
            "category": "Drama",
            "duration": 180,
            "thumbnail_url": "https://via.placeholder.com/400x225/000000/FFFFFF?text=GOT",
            "video_url": "sample.mp4"
        },
        {
            "title": "The Last of Us: Episode 1",
            "description": "Post-apocalyptic drama series",
            "category": "Drama",
            "duration": 3600,
            "thumbnail_url": "https://via.placeholder.com/400x225/000000/FFFFFF?text=TLOU",
            "video_url": "sample.mp4"
        },
        {
            "title": "Succession: Season Finale",
            "description": "Drama about a media empire",
            "category": "Drama",
            "duration": 4200,
            "thumbnail_url": "https://via.placeholder.com/400x225/000000/FFFFFF?text=Succession",
            "video_url": "sample.mp4"
        },
        {
            "title": "House of the Dragon",
            "description": "Targaryen dynasty prequel",
            "category": "Fantasy",
            "duration": 3900,
            "thumbnail_url": "https://via.placeholder.com/400x225/000000/FFFFFF?text=HOTD",
            "video_url": "sample.mp4"
        }
    ]
    
    for video_data in sample_videos:
        # Check if already exists
        existing = db.query(Video).filter(Video.title == video_data["title"]).first()
        if not existing:
            video = Video(**video_data)
            db.add(video)
    
    db.commit()
    
    return {"message": "Database seeded successfully", "videos_added": len(sample_videos)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
