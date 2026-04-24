import os
import logging
import numpy as np
from PIL import Image
import torch
from transformers import CLIPProcessor, CLIPModel

# Configure standard logging to display timestamps and execution levels cleanly.
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Set device and precision based on hardware availability
device = "cuda" if torch.cuda.is_available() else "cpu"
dtype = torch.float16 if device == "cuda" else torch.float32

# Load model and processor globally (outside function so it loads only once)
logger.info(f"Loading local CLIP model 'openai/clip-vit-base-patch32' on {device}...")
model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32", torch_dtype=dtype).to(device)
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

# Set model to evaluation mode
model.eval()

def generate_video_vector(frame_file_paths):
    """
    Convert a list of image frame paths into a single 512-dimensional vector 
    using a local CLIP model. Optimised with batch processing and hardware acceleration.
    """
    if not frame_file_paths:
        logger.error("No frame paths provided for vectorization.")
        return None

    try:
        # 1. Load and validate all images
        images = []
        for path in frame_file_paths:
            if os.path.exists(path):
                try:
                    img = Image.open(path).convert("RGB")
                    images.append(img)
                except Exception as e:
                    logger.warning(f"Failed to open image {path}: {e}")
        
        if not images:
            logger.error("No valid images found to process.")
            return None

        # 2. Batch preprocessing
        # Using return_tensors="pt" to get PyTorch tensors directly on the target device
        inputs = processor(images=images, return_tensors="pt", padding=True).to(device)

        # 3. Batch inference
        with torch.no_grad():
            # Step 1: Get visual features
            vision_outputs = model.vision_model(pixel_values=inputs.pixel_values.to(dtype))
            pooled = vision_outputs.pooler_output  # shape: (num_frames, 768)

            # Step 2: Project to 512-dimensional space
            projected = model.visual_projection(pooled)  # shape: (num_frames, 512)

            # Step 3: Compute mean across frames (mean pooling)
            # Doing this in Torch before moving to CPU is faster
            mean_vector_tensor = torch.mean(projected, dim=0)  # shape: (512,)
            
            # Move to CPU and convert to numpy
            mean_vector = mean_vector_tensor.cpu().float().numpy()

        logger.info(f"Batch processed {len(images)} frames successfully.")
        logger.info(f"Final vector shape: {mean_vector.shape} | preview: {mean_vector[:3]}")

        # Return as flat list of 512 floats
        return mean_vector.tolist()

    except Exception as e:
        logger.error(f"Batch vectorization failed: {str(e)}")
        return None
