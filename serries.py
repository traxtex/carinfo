import json
import re

import requests
from bs4 import BeautifulSoup
import time


def extract_series_info(item, category):
    series_info = dict()
    series_info['name'] = item.select_one('span[data-update=series_name]').text
    series_info['url'] = item.select_one('a[data-update=series_link]')['href']
    series_info['year'] = item.select_one('td[data-update=series_year]').text.strip()

    series_photo_div = item.find('div', class_='series_photo')
    if series_photo_div:
        style_attr = series_photo_div.get('style', '')
        url_match = re.search(r'url\((.*?)\)', style_attr)
        series_info["img_url"] = url_match.group(1).strip('"') if url_match else ''

    seats_info = item.find('span', attrs={'data-update': 'series_group_seats'})
    series_info['seats'] = seats_info.get_text(strip=True).replace('seats', '') if seats_info else None

    chassis_info = item.find('span', attrs={'data-update': 'series_group_chassis'})
    if chassis_info:
        series_info['chassis'] = chassis_info.find('span', class_='sep_item').get_text(strip=True)
    else:
        series_info['chassis'] = None

    engine_types_info = item.find('div', attrs={'data-update': 'series_group_engine_types'})
    if engine_types_info:
        series_info['engine_types'] = engine_types_info.find('span', class_='sep_item').get_text(strip=True)
    else:
        series_info['engine_types'] = None

    series_info['category'] = category
    print(series_info)
    return series_info


def fetch_series(url):
    response = requests.get(url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        series = []

        current_series = soup.find_all('tr', class_='series_item serie_current')
        print("found ", len(current_series), "current series")
        for item in current_series:
            series_info = extract_series_info(item, 'current')
            series.append(series_info)

        print("found ", len(current_series), "historic series")
        historic_series = soup.find_all('tr', class_='series_item serie_historic')
        for item in historic_series:
            series_info = extract_series_info(item, 'historic')
            series.append(series_info)

        return series
    return None


def main():
    with open('brands.json', 'r', encoding='utf-8') as file:
        brands = json.load(file)

    for i, brand in enumerate(brands, 1):
        print(f"Fetching series for brand {i}/{len(brands)}: {brand['Name']}")
        series_url = brand['URL']
        brand['series'] = fetch_series(series_url)
        time.sleep(1)

    with open('brands_with_series.json', 'w', encoding='utf-8') as file:
        json.dump(brands, file, indent=2)


def test():
    fetch_series("https://www.car.info/en-se/volkswagen")


if __name__ == '__main__':
    main()
