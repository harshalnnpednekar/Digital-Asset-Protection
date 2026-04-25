import os
import json
import base64
import logging
import tempfile
import shutil
from cryptography.fernet import Fernet
from stegano import lsb
import ffmpeg

# Configure logger
logger = logging.getLogger(__name__)

def inject_watermark(video_file_path, distribution_target, asset_id, temp_dir=None):
    """
    Embeds an invisible encrypted identifier into the first frame of the video.
    """
    # SECURITY NOTE — The encryption key is returned here for storage in Firestore
    # for demo purposes only. In production this key must be stored in Google Cloud
    # Secret Manager or equivalent HSM and never written to a database.
    working_dir = temp_dir
    created_temp_dir = False
    try:
        # Step 1: Generate Fernet key
        key = Fernet.generate_key()
        
        # Step 2: Create dictionary and encode to JSON bytes
        payload = {
            "distribution_target": distribution_target,
            "asset_id": asset_id
        }
        json_str = json.dumps(payload)
        json_bytes = json_str.encode('utf-8')
        
        # Step 3: Encrypt the payload
        f = Fernet(key)
        ciphertext_bytes = f.encrypt(json_bytes)
        
        # Step 4: Convert ciphertext to base64 string
        base64_str = base64.b64encode(ciphertext_bytes).decode('utf-8')
        
        working_dir = temp_dir or tempfile.mkdtemp(prefix='astra_watermark_')
        created_temp_dir = temp_dir is None

        frame_to_mark_path = os.path.join(working_dir, 'frame_to_mark.png')
        frame_marked_path = os.path.join(working_dir, 'frame_marked.png')
        watermarked_video_path = os.path.join(working_dir, 'watermarked_video.mp4')

        # Step 5: Extract the first frame as PNG
        (
            ffmpeg
            .input(video_file_path)
            .filter('select', 'eq(n,0)')
            .output(frame_to_mark_path, vframes=1, format='image2', vcodec='png')
            .overwrite_output()
            .run(capture_stdout=True, capture_stderr=True)
        )
        
        # Step 6: Embed base64 ciphertext into the PNG frame using LSB steganography
        secret = lsb.hide(frame_to_mark_path, base64_str)
        secret.save(frame_marked_path)
        
        # Step 7: Replace the first frame of the original video
        input_video = ffmpeg.input(video_file_path)
        input_image = ffmpeg.input(frame_marked_path)
        
        # Overlay the modified frame on the first frame of the video
        v = ffmpeg.overlay(input_video.video, input_image, enable='eq(n,0)')
        
        # Check if original video has an audio stream to preserve it
        try:
            probe = ffmpeg.probe(video_file_path)
            has_audio = any(stream['codec_type'] == 'audio' for stream in probe['streams'])
        except Exception:
            has_audio = False
            
        if has_audio:
            out = ffmpeg.output(v, input_video.audio, watermarked_video_path, acodec='copy', preset='ultrafast')
        else:
            out = ffmpeg.output(v, watermarked_video_path, preset='ultrafast')
            
        out.overwrite_output().run(capture_stdout=True, capture_stderr=True)
        
        # Step 8: Return the result dictionary
        return {
            "watermarked_video_path": watermarked_video_path,
            "encryption_key": key.decode('utf-8')
        }
        
    except Exception as e:
        logger.error(f"Failed to inject watermark: {e}")
        return None
    finally:
        if created_temp_dir and os.path.isdir(working_dir):
            shutil.rmtree(working_dir, ignore_errors=True)
