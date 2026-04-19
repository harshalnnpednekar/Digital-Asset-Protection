import os
import logging
import numpy as np
from PIL import Image
import torch
from transformers import CLIPProcessor, CLIPModel

# Configure standard logging to display timestamps and execution levels cleanly.
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Load model and processor globally (outside function so it loads only once)
logger.info("Loading local CLIP model 'openai/clip-vit-base-patch32'...")
model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

# Set model to evaluation mode
model.eval()

def generate_video_vector(frame_file_paths):
    """
    Convert a list of image frame paths into a single 512-dimensional vector 
    using a local CLIP model.
    """
    # 1. Create empty list
    all_vectors = []

    # 2. Loop through each image path
    for path in frame_file_paths:
        try:
            # a. Check if file exists
            if not os.path.exists(path):
                logger.warning(f"File skipped. Not found: {path}")
                continue
                
            # b. Open image using PIL
            image = Image.open(path).convert("RGB")

            # c. Preprocess image — processor returns only pixel_values for image input
            inputs = processor(images=image, return_tensors="pt")
            pixel_values = inputs["pixel_values"]  # shape: (1, 3, 224, 224)

            # d. Run vision encoder + linear projection directly (version-stable path)
            with torch.no_grad():
                # Step 1: vision encoder → CLS token pooled output: (1, 768)
                vision_outputs = model.vision_model(pixel_values=pixel_values)
                pooled = vision_outputs.pooler_output  # (1, 768)

                # Step 2: visual projection → projected embedding: (1, 512)
                projected = model.visual_projection(pooled)  # (1, 512)

            # e. Convert to numpy 1D vector
            extracted_vector = projected.detach().cpu().numpy()[0]  # shape: (512,)

            # Safety check: must be exactly (512,)
            if extracted_vector.shape != (512,):
                logger.warning(f"Unexpected vector shape {extracted_vector.shape} for {path}, skipping.")
                continue

            # f. Append vector to all_vectors
            all_vectors.append(extracted_vector)

            # 3. Logging (only path and 3-value preview — no full vector)
            logger.info(f"Processed frame: {path}")
            logger.info(f"Vector preview: {extracted_vector[:3]}")

        except Exception as e:
            # Skip failed frames
            logger.warning(f"Processing sequence aborted for vector mapping bound {path}: {str(e)}")
            
    # POST PROCESSING
    # 4. If all_vectors is empty
    if not all_vectors:
        # log ERROR and return None
        logger.error("Global sequence failure: No valid vectors processed. Failed dependency.")
        return None

    try:
        # CORRECT IMPLEMENTATION:
        # Convert list to numpy array:
        arr = np.array(all_vectors)
        
        # Compute mean across frames (arr must be 2D: num_frames x 512):
        mean_vector = np.mean(arr, axis=0)

        # Defensive squeeze: ensure output is always 1D before converting
        mean_vector = mean_vector.squeeze()

        logger.info(f"Final vector shape: {mean_vector.shape} | length: {len(mean_vector)}")

        # Return as flat list of 512 floats
        return mean_vector.tolist()
        
    except Exception as e:
        logger.error(f"Mathematical numpy mean mapping exception raised: {str(e)}")
        return None
