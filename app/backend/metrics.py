from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
from prometheus_fastapi_instrumentator import Instrumentator
import time

# Custom metrics
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

database_connection_errors_total = Counter(
    'database_connection_errors_total',
    'Total database connection errors'
)

active_users_gauge = Gauge(
    'active_users',
    'Number of active users'
)

videos_count_gauge = Gauge(
    'videos_total',
    'Total number of videos in database'
)

def setup_metrics(app):
    """Setup Prometheus metrics for FastAPI app"""
    
    # Use prometheus-fastapi-instrumentator for automatic metrics
    instrumentator = Instrumentator(
        should_group_status_codes=False,
        should_ignore_untemplated=True,
        should_respect_env_var=True,
        should_instrument_requests_inprogress=True,
        excluded_handlers=["/metrics"],
        env_var_name="ENABLE_METRICS",
        inprogress_name="http_requests_inprogress",
        inprogress_labels=True,
    )
    
    instrumentator.instrument(app).expose(app, endpoint="/metrics")
    
    return instrumentator
