import tempfile
import shutil
import logging
import uuid
from firebase_admin import firestore

from media_processor import extract_frames
from vectorizer import generate_video_vector
from threat_detector import compare_vectors, check_intent

logger = logging.getLogger(__name__)

def process_scraped_video(video_file_path: str, metadata_dict: dict):
    # Step 1: Create a unique temp directory for this scan job
    temp_dir = tempfile.mkdtemp(prefix="astra_scan_")
    
    try:
        # Step 2: Call extract_frames
        frame_paths = extract_frames(video_file_path, temp_dir)
        
        # Step 3: Call generate_video_vector
        scraped_vector = generate_video_vector(frame_paths)
        if scraped_vector is None:
            logger.warning(f"Vector generation failed for {video_file_path}")
            return
            
        # Step 4 & 5: Query Firestore and find best match in batch
        db = firestore.client()
        vaulted_assets_ref = db.collection("vaulted_assets")
        vaulted_assets = list(vaulted_assets_ref.stream())
        
        from threat_detector import find_best_match
        highest_similarity, matched_asset_doc = find_best_match(scraped_vector, vaulted_assets)
                
        # Step 6: If similarity < 0.82
        if highest_similarity < 0.82:
            logger.info(f"Score: {highest_similarity:.4f} - no threat detected for {video_file_path}")
            return
            
        # Step 7: If similarity >= 0.82
        caption = metadata_dict.get("caption", "")
        intent_result = check_intent(caption)
        
        # Step 8: If FAIR_USE
        if intent_result.get("intent") == "FAIR_USE":
            logger.info("fair use detected no alert created")
            return
            
        # Step 9: If PIRACY
        if intent_result.get("intent") == "PIRACY":
            write_threat_alert(video_file_path, metadata_dict, matched_asset_doc, highest_similarity, intent_result)

    finally:
        # Clean up temp dir
        try:
            shutil.rmtree(temp_dir)
        except Exception as e:
            logger.error(f"Failed to clean up temp directory {temp_dir}: {e}")


def write_threat_alert(video_file_path, metadata_dict, matched_asset_doc, similarity_score, intent_result):
    """
    Writes the confirmed threat to Firestore.
    """
    db = firestore.client()
    threat_id = str(uuid.uuid4())
    
    doc_data = matched_asset_doc.to_dict()
    matched_asset_id = matched_asset_doc.id
    matched_asset_name = doc_data.get("asset_name", "Unknown Asset")
    patient_zero = doc_data.get("distribution_target", "Unknown Target")
    
    # Audio fingerprinting is not implemented yet, so keep the metric neutral.
    audio_similarity = 0.0
    
    threat_data = {
        "threat_id": threat_id,
        "matched_asset_id": matched_asset_id,
        "matched_asset_name": matched_asset_name,
        "platform": metadata_dict.get("platform", "Unknown"),
        "source_url": metadata_dict.get("url", ""),
        "caption": metadata_dict.get("caption", ""),
        "visual_similarity": round(similarity_score, 4),
        "audio_similarity": audio_similarity,
        "gemini_intent": "PIRACY",
        "gemini_confidence": intent_result.get("confidence_score", 0.5),
        "gemini_reasoning": intent_result.get("reasoning", "No reasoning available."),
        "status": "ACTIVE",
        "detected_at": firestore.SERVER_TIMESTAMP,
        "patient_zero": patient_zero
    }

    # Write to threat_alerts
    db.collection("threat_alerts").document(threat_id).set(threat_data)
    
    # Write 3 contagion nodes
    nodes_ref = db.collection("contagion_nodes")
    
    # ROOT node
    nodes_ref.add({
        "node_id": "N0",
        "threat_id": threat_id,
        "type": "ROOT",
        "label": patient_zero,
        "platform": metadata_dict.get("platform", "Internal"),
        "url": metadata_dict.get("url", ""),
        "parent_id": None,
    })
    
    # MIRROR node
    nodes_ref.add({
        "node_id": "N1",
        "threat_id": threat_id,
        "type": "MIRROR",
        "label": f"{metadata_dict.get('platform', 'Unknown')} Mirror",
        "platform": metadata_dict.get("platform", "Unknown"),
        "url": metadata_dict.get("url", ""),
        "source_url": metadata_dict.get("url", ""),
        "parent_id": "N0",
    })
    
    # SOCIAL_RESHARE node
    nodes_ref.add({
        "node_id": "N2",
        "threat_id": threat_id,
        "type": "SOCIAL_RESHARE",
        "label": "Twitter Reshare",
        "platform": "Twitter",
        "url": f"https://twitter.com/{metadata_dict.get('uploader', 'unknown')}/status/reshare",
        "source_url": metadata_dict.get("url", ""),
        "parent_id": "N1",
    })
    
    logger.info(f"SUCCESS: Created threat alert {threat_id} for scraped video.")
