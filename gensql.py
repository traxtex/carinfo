import json


def main():
    with open('carsdata-fixed.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    for brand in data:
        bid = brand['bid']
        bname = brand['name']
        bcountry = brand['country']
        bcountry_code = brand['country_code']
        bcountry_logo = brand['country_logo_url']
        brand_logo = brand['brand_logo_url']
        byear = brand['year']

        insert_brand_query = f"INSERT INTO vehicle_brands (bid, name, country, country_code, country_logo_url, brand_logo_url, year, vehicle_type)VALUES('{bid}','{bname}','{bcountry}','{bcountry_code}','{bcountry_logo}','{brand_logo}','{byear}',1);"
        print(insert_brand_query)
        for sr in brand.get('series', []):
            insert_serie = f"INSERT INTO vehicle_series (sid, name, year, img_url, seats, chassis, engine_types, category, bid)VALUES('{sr['sid']}', '{sr['name']}', '{sr['year']}', '{sr['img_url']}', '{sr['seats']}', '{sr['chassis']}', '{sr['engine_types']}', '{sr['category']}', '{bid}');"
            print(insert_serie)


if __name__ == "__main__":
    main()
