import firebase_admin
from firebase_admin import credentials, firestore, storage


# Initialize Firebase Admin SDK
cred = credentials.Certificate('config/serviceAccountKey.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'solution-gdg.appspot.com'
})

# Get Firestore client
db = firestore.client()

# Get Storage bucket
bucket = storage.bucket()

print("Firebase Admin initialized successfully!")

# Example: Access collections
vaulted_assets_ref = db.collection('vaulted_assets')
threat_alerts_ref = db.collection('threat_alerts')
contagion_nodes_ref = db.collection('contagion_nodes')
system_state_ref = db.collection('system_state')

print("Collections references created.")
