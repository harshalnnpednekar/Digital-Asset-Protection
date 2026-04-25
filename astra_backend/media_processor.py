import ffmpeg
import os
import logging

# Configure basic logging for the module
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def extract_frames(video_file_path: str, output_directory: str) -> list:
    """
    Extracts frames from a given video file.
    Specifically extracts 1 frame every 2 seconds, scales the frames to 224x224, 
    and limits the output to a maximum of 30 frames.
    
    Args:
        video_file_path (str): The path to the source video file.
        output_directory (str): The destination directory to save the jpeg frames.
        
    Returns:
        list: A sorted list of file paths to the extracted frames. Returns an empty list if extraction fails.
    """
    # Ensure the output directory exists before writing to it
    os.makedirs(output_directory, exist_ok=True)
    
    # Define the output pattern for ffmpeg to output frame_0001.jpg, frame_0002.jpg, etc.
    output_pattern = os.path.join(output_directory, "frame_%04d.jpg")
    
    try:
        # Build the FFmpeg command using the ffmpeg-python library wrapper
        (
            ffmpeg
            .input(video_file_path)
            # Apply fps=1/2 filter: extract 1 frame every 2 seconds
            # Apply scale=224:224 filter: resize exactly to 224 by 224 pixels
            .filter('fps', fps='1/2')
            .filter('scale', 224, 224)
            # Output directly handling the pattern without audio, specifying standard JPEG quality (qscale=2)
            .output(output_pattern, **{'qscale:v': 2})
            # Overwrite output files seamlessly if they exist (-y passed as overwrite_output mechanism)
            .overwrite_output()
            # Execute the command and capture error logs in standard error
            .run(capture_stdout=True, capture_stderr=True)
        )
        logger.info(f"Successfully extracted frames from {video_file_path} to {output_directory}")
        
    except ffmpeg.Error as e:
        # If extraction fails, log the specific stderr captured by ffmpeg-python
        error_message = e.stderr.decode('utf-8') if e.stderr else str(e)
        logger.error(f"FFmpeg frame extraction failed for {video_file_path}: {error_message}")
        # Return an empty list upon failure directly
        return []
    
    # Collect all generated frames in the target directory
    # Only pick JPEG files to ensure we don't pick up unrelated items
    frame_files = [f for f in os.listdir(output_directory) if f.startswith("frame_") and f.endswith(".jpg")]
    
    # Join with the directory path to yield full file paths, and sort them sequentially
    full_frame_paths = sorted([os.path.join(output_directory, f) for f in frame_files])
    
    # CRITICAL RULE: Limit maximum frames array to exactly 30 instances
    if len(full_frame_paths) > 30:
        logger.warning("Frame limit applied: Exceeded 30 extracted frames.")
        full_frame_paths = full_frame_paths[:30]
        
    return full_frame_paths


def extract_audio_fingerprint(video_file_path: str, output_directory: str) -> str:
    """
    Strips the audio track from the media and saves it as a WAV file.
    
    Args:
        video_file_path (str): The path to the source video file.
        output_directory (str): The destination directory to place the exported wav file.
        
    Returns:
        str: Expected file path to the audio file on success, None on failure.
    """
    os.makedirs(output_directory, exist_ok=True)
    audio_output_path = os.path.join(output_directory, "audio.wav")
    
    try:
        # Build the FFmpeg command targetting solely audio stream extraction
        (
            ffmpeg
            .input(video_file_path)
            # Only dump the audio layout (-vn drops video) and output as wav
            .output(audio_output_path, vn=None, acodec='pcm_s16le', ac=1, ar='16000')
            .overwrite_output()
            .run(capture_stdout=True, capture_stderr=True)
        )
        logger.info(f"Successfully extracted audio fingerprint to {audio_output_path}")
        return audio_output_path
        
    except ffmpeg.Error as e:
        error_message = e.stderr.decode('utf-8') if e.stderr else str(e)
        logger.error(f"FFmpeg audio extraction failed for {video_file_path}: {error_message}")
        # Explicitly return None on failure
        return None
