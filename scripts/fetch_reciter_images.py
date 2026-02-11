import urllib.request
import urllib.error
import urllib.parse
import json
import os
import re
import time
import random

# Constants
RECITERS_API = "https://mp3quran.net/api/v3/reciters?language=ar"
# Relative to where script is run (inside scripts/) or from root
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
IMAGES_DIR_ABS = os.path.join(PROJECT_ROOT, "assets", "images", "reciters")

# Headers to mimic a browser
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

def ensure_dir(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

def fetch_reciters():
    print("Fetching reciters list...")
    try:
        req = urllib.request.Request(RECITERS_API, headers=HEADERS)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            return data.get("reciters", [])
    except Exception as e:
        print(f"Error fetching reciters: {e}")
        return []

def simple_scrape_google_images(query):
    # Search google images using urllib
    # Note: query needs to be url encoded
    encoded_query = urllib.parse.quote(query)
    search_url = f"https://www.google.com/search?site=&tbm=isch&source=hp&biw=1873&bih=990&q={encoded_query}"
    
    try:
        req = urllib.request.Request(search_url, headers=HEADERS)
        with urllib.request.urlopen(req) as response:
            html = response.read().decode('utf-8', errors='ignore')
            
            # Regex for google thumbs
            # Google thumbs usually start with https://encrypted-tbn0.gstatic.com/images
            matches = re.findall(r'https://encrypted-tbn0.gstatic.com/images\?q=tbn:[\w\-]+', html)
            if matches:
                return matches[0] # Return the first thumbnail
    except Exception as e:
        print(f"Error scraping {query}: {e}")
    return None

def download_image(url, file_path):
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req) as response:
            with open(file_path, 'wb') as f:
                f.write(response.read())
            return True
    except Exception as e:
        print(f"Failed to download image from {url}: {e}")
        return False

def main():
    ensure_dir(IMAGES_DIR_ABS)
    print(f"Saving images to: {IMAGES_DIR_ABS}")
    
    reciters = fetch_reciters()
    print(f"Found {len(reciters)} reciters.")

    count = 0
    for reciter in reciters:
        reciter_id = reciter.get('id')
        name = reciter.get('name')
        
        if not reciter_id or not name:
            continue

        file_path = os.path.join(IMAGES_DIR_ABS, f"{reciter_id}.jpg")
        
        if os.path.exists(file_path):
            # print(f"Image for {name} ({reciter_id}) already exists. Skipping.")
            continue

        print(f"[{count+1}/{len(reciters)}] Searching for {name} ({reciter_id})...")
        # Add "sheikh" or "reciter" to query to be more specific
        query = f"القارئ {name}" 
        image_url = simple_scrape_google_images(query)
        
        if image_url:
            if download_image(image_url, file_path):
                print(f"Saved: {reciter_id}.jpg")
            
            # Sleep to identify as human
            time.sleep(random.uniform(1.0, 3.0)) 
        else:
            print(f"No image found for {name}")
        
        count += 1
        # Optional: break after a few for testing? No, user wants all.
        # But for this environment let's do a batch or just let it run.

if __name__ == "__main__":
    main()
