import os
import logging
import sys
from media_processor import extract_frames, extract_audio_fingerprint
from vectorizer import generate_video_vector

# Configure basic logging for the test script
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    """
    Main testing pipeline to verify frame extraction, audio extraction,
    and vector generation work end-to-end.
    """
    try:
        # Define the test inputs and outputs
        video_path = "test_video.mp4"
        output_dir = "temp/test_run"

        logger.info(f"Starting ASTRA AI Pipeline Test on {video_path}")

        # Ensure the test video actually exists before proceeding
        if not os.path.exists(video_path):
            logger.error(f"Test video '{video_path}' not found in the current directory.")
            return

        # 3. Create output directory: "temp/test_run"
        # exist_ok=True ensures we don't crash if the folder already exists
        logger.info(f"Creating output directory at: {output_dir}")
        os.makedirs(output_dir, exist_ok=True)

        # ==========================================
        # STEP 1: Extract frames
        # ==========================================
        logger.info("=== STEP 1: Extracting Frames ===")
        # Call the extract_frames function which returns a list of file paths
        frame_paths = extract_frames(video_file_path=video_path, output_directory=output_dir)
        
        # Check if frames were successfully extracted
        num_frames = len(frame_paths)
        logger.info(f"Number of frames extracted: {num_frames}")
        
        if num_frames == 0:
            logger.error("Failed to extract any frames. STOP.")
            return # STOP execution here if no frames were found

        # ==========================================
        # STEP 2: Extract audio
        # ==========================================
        logger.info("=== STEP 2: Extracting Audio Fingerprint ===")
        # Call the extract_audio_fingerprint function
        audio_path = extract_audio_fingerprint(video_file_path=video_path, output_directory=output_dir)
        
        # Check if audio was extracted
        if audio_path:
            logger.info(f"Successfully extracted audio to: {audio_path}")
        else:
            logger.error("Failed to extract audio fingerprint.")

        # ==========================================
        # STEP 3: Generate vector
        # ==========================================
        logger.info("=== STEP 3: Generating Video Vector ===")
        # Pass the list of frame paths to generate_video_vector
        video_vector = generate_video_vector(frame_paths)
        
        # Check if the vector generation was successful
        if video_vector is None:
            logger.error("Failed to generate video vector. STOP.")
            return # STOP execution here if vector generation fails

        # ==========================================
        # Print final results
        # ==========================================
        print("\n===== FINAL OUTPUT =====")
        print(f"Frames extracted: {len(frame_paths)}")
        print(f"Audio extracted: {'YES' if audio_path else 'NO'}")
        print(f"Vector length: {len(video_vector)}")
        print(f"Vector preview: {video_vector[:5]}")
        print("Pipeline completed successfully!")

    except Exception as e:
        # Catch unexpected errors to prevent the script from crashing abruptly
        logger.error(f"An unexpected error occurred during pipeline execution: {str(e)}")

# This block ensures that main() is called only when this script is run directly
if __name__ == "__main__":
    main()
