"""
Windows-specific utilities for VoiceForge
"""

import sys
import ctypes
import subprocess
from pathlib import Path
import os


class WindowsUtils:
    """Windows-specific utility functions."""
    
    @staticmethod
    def is_windows() -> bool:
        """Check if running on Windows."""
        return sys.platform == 'win32'
    
    @staticmethod
    def get_windows_version():
        """Get Windows version."""
        import platform
        return platform.version()
    
    @staticmethod
    def is_windows_10_or_11() -> bool:
        """Check if Windows 10 or 11."""
        import platform
        ver = platform.version()
        # Windows 10 = 10.0.19041+, Windows 11 = 10.0.22000+
        return ver.startswith('10.0')
    
    @staticmethod
    def set_app_user_model_id(app_id: str = "ForraCorp.VoiceForge"):
        """Set Windows App User Model ID for taskbar integration."""
        if sys.platform == 'win32':
            try:
                ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(app_id)
                return True
            except:
                return False
        return False
    
    @staticmethod
    def open_file_explorer(path: str):
        """Open Windows File Explorer at specified path."""
        if sys.platform == 'win32':
            subprocess.Popen(["explorer", path])
    
    @staticmethod
    def get_app_data_path() -> Path:
        """Get Windows AppData path."""
        if sys.platform == 'win32':
            appdata = os.getenv('APPDATA')
            if appdata:
                return Path(appdata) / 'VoiceForge'
        return Path.home() / '.voiceforge'
    
    @staticmethod
    def pin_to_taskbar():
        """Pin application to Windows taskbar."""
        # Windows 10/11 pinning requires COM automation
        # This is a complex operation, usually requires user interaction
        pass