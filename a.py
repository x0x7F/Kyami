import json
import os
import hashlib

# --- Configuration ---
INPUT_JSON = 'books_data.json'
OUTPUT_DIR = './web_data/'

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

def generate_id(text):
    """Generates a consistent 6-character random-looking ID from text"""
    return hashlib.md5(text.encode('utf-8')).hexdigest()[:6]

with open(INPUT_JSON, 'r', encoding='utf-8') as f:
    data = json.load(f)

all_books = data['books']
category_map = {}
category_index = []

print("⚡ Splitting files with Random IDs...")

for book in all_books:
    for cat in book['categories']:
        original_name = cat['name']
        
        # Generate the random-looking slug (e.g., 'e4d912')
        cat_id = generate_id(original_name)
        
        if cat_id not in category_map:
            category_map[cat_id] = []
            category_index.append({
                "id": cat['id'],
                "name": original_name, # Keep original name for display in UI
                "slug": cat_id,        # Use random ID for filename
                "emoji": cat.get('emoji', '📚'),
                "count": 0
            })
        
        category_map[cat_id].append(book)

# 2. Save individual JSON files
for item in category_index:
    slug = item['slug']
    books_in_cat = category_map.get(slug, [])
    item['count'] = len(books_in_cat)
    
    file_path = os.path.join(OUTPUT_DIR, f"{slug}.json")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(books_in_cat, f, ensure_ascii=False) # Minified for performance

# 3. Save the main Index
with open(os.path.join(OUTPUT_DIR, 'categories_index.json'), 'w', encoding='utf-8') as f:
    json.dump(category_index, f, ensure_ascii=False)

print(f"✅ Success! Created {len(category_index)} files in '{OUTPUT_DIR}'")
