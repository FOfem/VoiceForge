"""
VoiceForge - Personal Voice Model Training Studio
Version: 1.0.0
"""

__version__ = "1.0.0"
__author__ = "Fredrick O. Ubi"
__email__ = "fofem@forracorp.com"
__license__ = "MIT"

# ✅ FIX: Import main components
from .main import VoiceForgeApp
from .recorder import AudioRecorder
from .trainer import VoiceTrainer

__all__ = ['VoiceForgeApp', 'AudioRecorder', 'VoiceTrainer']
