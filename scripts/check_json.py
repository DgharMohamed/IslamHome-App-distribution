import json
import os

def check_json_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Check basic structure expected by Dart code
        if isinstance(data, list):
            print(f"[OK] {filepath}: Root is List with {len(data)} items")
            return True
        elif isinstance(data, dict):
            if 'hadiths' in data and isinstance(data['hadiths'], list):
                print(f"[OK] {filepath}: Root is Dict with 'hadiths' list of {len(data['hadiths'])} items")
                return True
            else:
                 print(f"[WARNING] {filepath}: Root is Dict but missing 'hadiths' list or it's not a list")
                 return False
        else:
            print(f"[ERROR] {filepath}: Root is neither List nor Dict")
            return False

    except json.JSONDecodeError as e:
        print(f"[ERROR] {filepath}: Invalid JSON - {e}")
        return False
    except Exception as e:
        print(f"[ERROR] {filepath}: {e}")
        return False

base_dir = r'c:\Users\Batman\Desktop\Portfolio Projects\IslamicLibraryApp\islamic_library_flutter\assets\data'

hadith_dir = os.path.join(base_dir, 'hadith')
nawawi_dir = os.path.join(base_dir, 'nawawi')

files_to_check = []

if os.path.exists(hadith_dir):
    for f in os.listdir(hadith_dir):
        if f.endswith('.json'):
            files_to_check.append(os.path.join(hadith_dir, f))

if os.path.exists(nawawi_dir):
    for f in os.listdir(nawawi_dir):
        if f.endswith('.json'):
            files_to_check.append(os.path.join(nawawi_dir, f))

print(f"Checking {len(files_to_check)} files...")
for f in files_to_check:
    check_json_file(f)
