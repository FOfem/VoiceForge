"""
CLI / Direct launch entry point redirecting to main application GUI.
"""

# ✅ FIX: Import main from app.py, not the other way around
from src.app import main

if __name__ == "__main__":
    main()
