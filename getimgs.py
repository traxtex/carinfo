import json
import os
import uuid

import requests


def download_image(url, filename):
    if url is None or len(url) == 0:
        return
    print(f'download:{url}')
    response = requests.get(url)
    if response.status_code == 200:
        with open(filename, 'wb') as f:
            f.write(response.content)
        print(f"Downloaded {filename}")
    else:
        print(f"Failed to download {filename}")


def main():
    # Load the JSON data
    with open('carinfo/brands_with_series.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Create directory structure
    os.makedirs('imgs/country', exist_ok=True)
    os.makedirs('imgs/brands', exist_ok=True)
    os.makedirs('imgs/series', exist_ok=True)

    # Generate unique ids and store them in the JSON data
    for brand in data:
        brand['bid'] = str(uuid.uuid4())
        for serie in brand.get('series', []):
            serie['sid'] = str(uuid.uuid4())

    # Save updated JSON data with unique ids
    with open('carsdata.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)

    # Download images and store using unique ids
    for brand in data:
        country_logo_url = brand['country_logo_url']
        country_code = brand['country_code']
        download_image(country_logo_url, f'imgs/country/{country_code}.svg')

        brand_id = brand['bid']
        brand_logo_url = brand['brand_logo_url']
        download_image(brand_logo_url, f'imgs/brands/{brand_id}.jpg')

        for serie in brand.get('series', []):
            serie_id = serie['sid']
            img_url = serie['img_url']
            download_image(img_url, f'imgs/series/{serie_id}.jpg')


if __name__ == "__main__":
    main()
