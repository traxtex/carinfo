import json


def main():
    base_url = "https://gh.traxtex.com"
    with open('carsdata.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Generate unique ids and store them in the JSON data
    for brand in data:
        country_code = brand.get('country_code')
        bid = brand.get('bid')
        brand['country_logo_url'] = f'{base_url}/imgs/country/{country_code}.svg'
        brand['brand_logo_url'] = f'{base_url}/imgs/brands/{bid}.jpg'
        for serie in brand.get('series', []):
            sid = serie.get('sid')
            serie['img_url'] = f'{base_url}/imgs/series/{sid}.jpg'

    with open('carsdata-fixed.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)


if __name__ == "__main__":
    main()
