from bs4 import BeautifulSoup
import urllib.request, urllib.parse, urllib.error
import re 
import numpy as np
import pandas as pd
import time
import os

url2 = 'https://www.booking.com/searchresults.en-gb.html?ss=Matera&ssne=Matera&ssne_untouched=Matera&label=gen173nr-1BCAEoggI46AdIM1gEaHGIAQGYARS4ARjIAQzYAQHoAQGIAgGoAgS4As60860GwAIB0gIkYTZmMWI3YmMtNWExNi00OWE2LTgxOGMtYThlMGNkNWUyNmM12AIF4AIB&sid=cae7c04b7f58624abedeb57d1a1e3341&aid=304142&lang=it&sb=1&src_elem=sb&src=index'
url = 'https://www.booking.com/searchresults.en-gb.html?ss=Matera&ssne=Matera&ssne_untouched=Matera&label=gen173nr-1FCAEoggI46AdIM1gEaHGIAQGYAQm4ARjIAQzYAQHoAQH4AQuIAgGoAgS4AubGlq8GwAIB0gIkMjgwMzE4NmMtN2YzMC00OWJkLWFiMzEtOWU0Mzc2NWE0MDNl2AIG4AIB&sid=cae7c04b7f58624abedeb57d1a1e3341&aid=304142&lang=en-gb&sb=1&src_elem=sb&src=index'
def create_url(url):
    '''
    Takes parameters and adds them to url. 
    Returns a list with urls for all pages of web search
    '''

    # Ask destination id
    destination_id = '&dest_id=-121381'  #+input('Type destination ID: ') #-121381 for Matera
    # Ask destination type
    destination_type = '&dest_type=city' #+input('Type destination type: ')
     #How many nights? For later use:
    nights = int(input('Number of total nights: '))
    # Ask check-in date
    checkin_date = '&checkin=2024-03-22'# +input('Type chech-in date (YYYY-MM-DD): ')
    # Ask check-out date
    checkout_date = '&checkout=2024-03-24' #+input('Type chech-out date (YYYY-MM-DD): ')
    # Ask number of adults
    adults = '&group_adults=2'# + input('Type number of adults: ') 
    # Ask number of children
    children = '&group_children=0'# +input('Type number of children: ')
    # Ask number of rooms
    rooms = '&no_rooms=1'#+ input('Type number of rooms: ')

    # Filters
    filters = []
    add_filters = input('Do you want to add filters? y/n: ')
    if add_filters == 'y':
        # Add filters based on user input
        if input('Do you want <1km filter? y/n: ') == 'y':
            filters.append('&nflt=distance%3D1000')
        if input('Do you want entire home filter? y/n: ') == 'y':
            filters.append('&nflt=privacy_type%3D3')
        if input('Do you want great reviews filter? y/n: ') == 'y':
            filters.append('&nflt=review_score%3D90')
        if input('Do you want apartment filter? y/n: ') == 'y':
            filters.append('&nflt=ht_id%3D201')

    # Ask different pages
    pagine = int(input('How many pages do you wish to check? (int): '))
    offset = pagine*25 + 1
    page = ['&offset=' + str(i) for i in range(1, offset, 25)]
    
    # Return the list of URLs for your web search
    new_urls = [url + destination_id + destination_type + checkin_date + checkout_date + adults + children + rooms + p for p in page]
    '''figure out why it doesn't append all filters chosen'''
    pages = len(new_urls)
    
    return new_urls, pages, nights

def get_html(url):
    #Loop over all pages retrieved and parse the html
    #for pages in new_urls:  
    
    html = urllib.request.urlopen(url).read()
    soup = BeautifulSoup(html, 'html.parser')
    
    return(soup)

def find_num_results(soup):

    resuuu = soup.find('h1', class_ = 'f6431b446c d5f78961c3')
    if resuuu is not None:
        number_of_results = int(re.search('[0-9]+', resuuu.text).group())
    else:
        return('No results')
        

    return(number_of_results)

def find_names(soup):
    name = []

    nomi = soup.find_all('div', class_ = 'f6431b446c a15b38c233')

    for nome in nomi:
        name.append(nome.text)

    return(name)

def find_rental_type(soup):

    rent_type = []
    type = soup.find_all('span', class_ = 'abf093bdfe e6208ee469')
    for one in type:
        if one is None:
            rent_type.append(False)
        else:
            rent_type.append(one.text)

    return(rent_type)

def find_prices(soup, nights):
    
    prices = []
    night_price = []
    discount_p = []

    prezzi = soup.find_all('div', class_ = 'ac4a7896c7')
    

    for prezzo in prezzi: 
       
        cash = re.findall(r'\b([0-9]+(?:.[0-9]{3})*)\b', prezzo.text)
        
        if len(cash) != 0:
            mon = cash

            if mon[0] == '0':
                del mon
            else:
                prices.append([int(cashy.replace('.', '')) for cashy in cash])

    for money in prices:
        if len(money) == 1:
            money.append(money[0])

    full_prices = [sublist[0] for sublist in prices]
    discount_prices = [sublist[1] for sublist in prices]

    for cash in discount_prices:
        onenight = round(cash/nights, ndigits=2)
        night_price.append(onenight)

    for bling in range(len(discount_prices)):
        full = full_prices[bling]
        discounted = discount_prices[bling]
        disc = round((full - discounted)/full,ndigits=2)
        discount_p.append(disc)
    

    return(full_prices, discount_prices, night_price, discount_p)

def find_ratings(soup):
    
    rating = []
    num_reviews = []
    loc_rating = []

    strutture = soup.find_all('div', class_ = 'aca0ade214 c9835feea9 c2931f4182 d79e71457a f02fdbd759')

    for struttura in strutture:
        print(struttura.prettify())
        found_ratings = struttura.find('div', class_ = 'a3b8729ab1 d86cee9b25')
        found_reviews_num = struttura.find('div', class_ = 'abf093bdfe f45d8e4c32 d935416c47')
        found_loc_ratings = struttura.find('span', class_ = 'a3332d346a')
       
        if found_ratings is None:
            found_ratings = float(8)
        else:
            found_ratings = float(found_ratings.text.replace(',','.'))
        
        rating.append(found_ratings)

        if found_loc_ratings is None:
            found_loc_ratings = float(8)
        else:
            match_obj = re.search('[0-9],[0-9]', found_loc_ratings.text)
            if match_obj is not None:
                found_loc_ratings = float(match_obj.group().replace(',','.'))
            else:
                found_loc_ratings = float(8)

        loc_rating.append(found_loc_ratings)        
        
        if found_reviews_num is None:
            found_reviews_num = int(0)
        else:
            match_obj = re.search(r"([+-]?(?=\.\d|\d)(?:\d+)?(?:\.?\d*))(?:[Ee]([+-]?\d+))?", found_reviews_num.text)
            if match_obj is not None:
                found_reviews_num = int(match_obj.group().replace('.',''))
            else:
                found_reviews_num = 0            
        num_reviews.append(found_reviews_num)

    return(rating, num_reviews, loc_rating)

def find_stars(soup):
    
    strutture = soup.find_all('div', class_ = 'aca0ade214 c9835feea9 c2931f4182 d79e71457a f02fdbd759')
    stars = []

    for struttura in strutture:
        stelle = struttura.find('div', class_ = 'b3f3c831be')
    
        if stelle is None:
            stelle = 3
            stars.append(stelle)
  
        else:
            stelle = int(re.search('[0-9]', stelle.attrs.get('aria-label')).group())
            stars.append(stelle)

    return(stars)

def find_programmes(soup):
    
    genius = []
    pref_partner = []
    featured = []

    strutture = soup.find_all('div', class_ = 'aca0ade214 aaf30230d9 cd2e7d62b0 b0db0e8ada') #'aca0ade214 c9835feea9 c2931f4182 d79e71457a f02fdbd759')

    for struttura in strutture:
        found_genius = struttura.find('span', {'data-testid' : 'genius-badge'})
        found_pref = struttura.find('span', {'data-testid' : 'preferred-badge'})
        found_feat = struttura.find('span', class_ = 'abf093bdfe c147fc6dd1 d516b1d73e')
        
        if found_genius is None:
            lab_genius = False
        else:
            lab_genius = True
        
        genius.append(lab_genius)

        if found_pref is None:
            pref_partner.append('No PP')
        else:
            levels = found_pref.find('span', class_ = 'fcd9eec8fb c2a6770498 b3d142134a c2cc050fb8 e410954d4b')
            if levels is not None:
                pref_partner.append('PP+')
            else:
                pref_partner.append('PP') 

        if found_feat is None:
            lab_feat = False
        else:
            lab_feat = True

        featured.append(lab_feat)    

    return(genius, pref_partner, featured)

def find_dist(soup):

    dist = []

    strutture = soup.find_all('div', class_ = 'aca0ade214 c9835feea9 c2931f4182 d79e71457a f02fdbd759')

    for struttura in strutture:
        
        datum = struttura.find('span', {'data-testid' : 'distance'})

        distance = re.search(r'[0-9]+(?:,[0-9]+)? km', datum.text)

        if distance is not None:
            disty = float(re.search(r'[0-9]+(?:,[0-9]+)?', datum.text).group().replace(',','.'))
            dist.append(disty)

        else:
             distance = re.search('[0-9]+', datum.text)
             if distance is not None:
                  disty = float(distance.group())/1000
                  dist.append(disty)
    
    return(dist)

def find_trav_sustainability(soup):

    sustainability = []

    strutture = soup.find_all('div', class_ = 'aca0ade214 c9835feea9 c2931f4182 d79e71457a f02fdbd759')

    for struttura in strutture:
        
        datum = struttura.find('span', class_ = 'abf093bdfe d068504c75 f68ecd98ea')

        if datum is None:
            datum = '0'
        else:
            datum = re.search('[0-9]', datum.text).group()
        
        sustainability.append(datum)

    return(sustainability)     

def find_rent_types(soup):

    type = []   

    datum = soup.find_all('div', {'data-testid' : 'recommended-units'})
 
    for data in datum:
        type.append(data.find('h4', class_ = 'abf093bdfe e8f7c070a7').text)
                
    return(type)

def find_deal(soup):

    deal = []
    deal_type = []

    strutture = soup.find_all('div', class_ = 'c1edfbabcb')
    for struttura in strutture:
        search = struttura.find('span', class_ ='abf093bdfe c147fc6dd1 d18b4a6026')

        if search is None:
            deal.append(False)
            deal_type.append('None')
        
        else:
            deal.append(True)
            deal_type.append(search.find('span', class_ = 'b30f8eb2d6').text)
        
    return(deal, deal_type)

def find_policies(soup):

    free_cancellation = []
    pay_later = []
    breakfast_inc = []

    datum = soup.find_all('div', class_ = 'c19beea015')    #('div', {'data-testid' : 'recommended-units'})

    for data in datum:
        list = data.find('ul', class_ = 'ba51609c35')

        if list is None:
            breakfast_inc.append(False)
            free_cancellation.append(False)
            pay_later.append(False)
        else:
            colazione = list.find('span', class_ = 'a19404c4d7')
            if colazione is None:
                breakfast_inc.append(False)
            else:
                breakfast_inc.append(True)
            
            pol = list.find_all('div', class_ = 'abf093bdfe d068504c75')
            if len(pol) == 0:
                free_cancellation.append(False)
                pay_later.append(False)
            
            elif len(pol) == 1:
                txt = pol[0].text
                if txt == 'Cancellazione gratuita':
                    free_cancellation.append(True)
                    pay_later.append(False)             
                if txt == 'Senza pagamento anticipato – Paga in struttura':
                    pay_later.append(True)
                    free_cancellation.append(False)

            else:
                pay_later.append(True)
                free_cancellation.append(True)

    return(free_cancellation, pay_later, breakfast_inc)

def find_newprop(soup):

    new_property = []

    strutture = soup.find_all('div', class_ = 'aca0ade214 ebac6e22e9 cd2e7d62b0 a0ff1335a1')

    for struttura in strutture:
        new_to_book = struttura.find('span', class_ = 'abf093bdfe c147fc6dd1 d8d1f2a629')
        
        if new_to_book is not None:
            new_property.append(True)
        else:
            new_property.append(False)

    return(new_property)


def create_df(data, cols, filename, cause):
    new_cols = ['Rank', 'Nightly Price', 'Discount Prices', 'Full Prices', 'Discount %', 'Ratings',  'Number of Reviews', 'Location Ratings', 'Genius', 'Preferred Partner', 'Featured', 'Deal', 'Deal type', 'Distance', 'Stars', 'Free Cancellation', 'Breakfast included', 'Pay later', 'Travel Sustainability', 'New property']#, 'Rental type']
    dati = np.array(data)
    df = pd.DataFrame(dati, columns = cols).transpose()
    df.columns = new_cols
    if cause=='r':
        file_path = os.path.join('C:\\Users\\Utente\\Desktop\\Cappelluti1924\\Dati\\Dati alla prenotazione', filename + '.tsv')
    elif cause=='p':
        file_path = os.path.join('C:\\Users\\Utente\\Desktop\\Cappelluti1924\\Dati\\Pricing', filename + '.tsv')
    else:
        file_path = os.path.join('C:\\Users\\Utente\\Desktop\\Cappelluti1924\\Dati\\Dataset vari', filename + '.tsv')
    df.to_csv(file_path, sep='\t', index=True)
    return(df)


def init():

    rank = []
    names = []
    night_price = []
    discount_p = []
    full_prices = []
    discount_prices = []
    ratings = []
    number_of_reviews = []
    location_ratings = []
    genius = []
    pref_partner = []
    featured = []
    deal = []
    deal_type = []
    distance = []
    stars = []
    free_cancellation = []
    breakfast_inc = []
    pay_later = []
    travel_sustainability = []
    new_prop = []
    rental_type = []

    return [rank, names, night_price, discount_prices, full_prices, discount_p, ratings,  number_of_reviews, location_ratings, genius, pref_partner, featured, deal, deal_type, distance, stars,free_cancellation,breakfast_inc,pay_later,travel_sustainability,new_prop, rental_type]
    
def start(): 

    lists = init()
    rank, names, night_price, discount_prices, full_prices, discount_p, ratings, number_of_reviews, location_ratings, genius, pref_partner, featured, deal, deal_type, distance, stars, free_cancellation, breakfast_inc, pay_later, travel_sustainability, new_prop, rental_type = lists
    
    filename = input('What do you want to call the csv file?: ')
    cause = input('Reservation, Pricing or Other? R/P/O: ')

    url = 'https://www.booking.com/searchresults.it.html?ss=Matera&ssne=Matera&ssne_untouched=Matera&label=gen173nr-1FCAEoggI46AdIM1gEaHGIAQGYARS4ARfIAQzYAQHoAQH4AQuIAgGoAgO4AqCEl68GwAIB0gIkMTg1N2I0OGYtNDI1Yy00NTI1LWIyMTgtMDNlZTQ1MGM0YTRj2AIG4AIB&sid=8e329deb2362ab2f4fb098905adb8a10&aid=304142&lang=it&sb=1&src_elem=sb&src=index'
    
    new_urls, pages, nights = create_url(url)

    for page in range(pages):

        time.sleep(15)
                            
        req = urllib.request.Request(
                new_urls[page], 
                data=None, 
                headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
               'sid' : '8e329deb2362ab2f4fb098905adb8a10', 
               'Cookie' : 'px_init=0; _gcl_au=1.1.1173591315.1705610425; _rdt_uuid=1705610425215.f723458c-351c-40ce-869b-b0b62b878dae; _fbp=fb.1.1705610429268.259345370; _vs=5273264723241686255:1705610443.8448882:6369189895168196484; _ga_PJSQX7HV9H=GS1.1.1705610429.1.1.1705610496.0.0.0; _ga_G0GLDX0JXR=GS1.1.1705611396.1.1.1705611485.0.0.0; cors_js=1; OptanonAlertBoxClosed=2024-01-18T20:58:17.012Z; _ga_P07TP8FRGZ=GS1.1.1705611486.1.1.1705613090.0.0.0; _ga_4GY873RFCC=GS1.1.1705611526.1.1.1705613092.0.0.0; _scid=0a7c74d6-93b3-4097-b6fa-e8828a423550; FPID=FPID2.2.aC94P0aopgjNob8YBZ8SrFmiSGeUWBWnuMT3jjpakVc%3D.1705610429; _pin_unauth=dWlkPU9XUXpOemxpTUdJdE1HSXlaUzAwWXpGakxUZ3pPVFV0WTJJd1pqUTVNekF3WW1Gag; _pxvid=65980927-c467-11ee-b305-dff5e2a85da2; bkng_sso_ses=eyJib29raW5nX2dsb2JhbCI6W3siaCI6IkpnczB5SVJ5YnZpL2tWVWdBQWhZWVM4V1JiejZHbUc1Qnc2SnNjeFFDcDAifV19; bkng_sso_session=eyJib29raW5nX2dsb2JhbCI6W3sibG9naW5faGludCI6IkpnczB5SVJ5YnZpL2tWVWdBQWhZWVM4V1JiejZHbUc1Qnc2SnNjeFFDcDAifV19; pcm_consent=consentedAt%3D2024-02-08T09%3A44%3A05.024Z%26countryCode%3DIT%26expiresAt%3D2024-08-06T09%3A44%3A05.024Z%26implicit%3Dfalse%26regionCode%3D72%26regulation%3Dgdpr%26legacyRegulation%3Dgdpr%26consentId%3D24bcb07d-dddb-4a38-849b-e693c9e13e30%26analytical%3Dtrue%26marketing%3Dtrue; bkng_sso_auth=CAIQsOnuTRqIAVCia+x7KQiH4KbQPbjPePm9+nPXexZlxkXhGZvjHe5pL4ZMq/721Ty4VwFkpzROGYlNmTOljrieoPK56KOZS1kDY8p24MgcGTU7Y36K0pZPn1I0NfWDcTJmAC7QLPMsz0sKFVzoTKWCeJByqFp92ZbzrhBJo7PmvLre5oYHXs9O91pH1qzNr5o=; BJS=-; _gid=GA1.2.1705941739.1710515039; _gat=1; bkng_prue=1; FPLC=6uGrtE4XBJbRwY19QX98iJFdLEWkmUvZVBp2CLmNdzdky2of7L0hLRF4fWvYqRrabeXzzDs2pEmog8hyYZBxA28bpPPau6tqNFWJTeZ%2FjISl53U2eLubNNc%2B%2FzhfDg%3D%3D; OptanonConsent=implicitConsentCountry=GDPR&implicitConsentDate=1705611486933&isGpcEnabled=0&datestamp=Fri+Mar+15+2024+16%3A04%3A09+GMT%2B0100+(Ora+standard+dell%E2%80%99Europa+centrale)&version=202401.2.0&browserGpcFlag=0&isIABGlobal=false&hosts=&consentId=0261e2d7-325c-43ae-9990-2487208f1903&interactionCount=1&landingPath=NotLandingPage&groups=C0001%3A1%2CC0002%3A1%2CC0004%3A1&backfilled_at=1705611497585&backfilled_seed=1&geolocation=IT%3B72&AwaitingReconsent=false; _ga_A12345=GS1.1.1710515040.9.1.1710515049.0.0.0; _ga=GA1.1.395161325.1705610429; _scid_r=0a7c74d6-93b3-4097-b6fa-e8828a423550; _uetsid=41686510e2dd11ee85cb65c4a1ee0f9e; _uetvid=c869ae70c12111eeb2e9e1fcc1b6b993; cgumid=d65JWjPihj3NHppgNF8sSA3cL-JmyPt8; cto_bundle=dyK-nl80THdGR1olMkJ3WmI1ekpWaE9uWkhuUDJaa0MwckozN2xzTU1JRXdhR3E5Vzg0VndwalBKMzc4N0NIUFJOWjZoZSUyQnd5eVFTeXppTWUxb2plb0YxbWdYeFI3V1JEeUNOTlA3VWptR1RhM1NIZ3pkdkhkWmI3ZVNhQjZubkIzZFJwQkRYWlhjdHVVbzJZZENLOVRhaE5wSHpnJTNEJTNE; bkng=11UmFuZG9tSVYkc2RlIyh9Yaa29%2F3xUOLbLpunidpvsIibjAJG7J25gw7jBFUmz7Ttkzz%2BJt3YlWSxqcMlW9Q1cMM7XVLE3uq4qpwljHmLCL46Dt25eoabFpdV%2B05a%2FO5VGU8CeTxR9RtKOkshsRaiZ3Ljis4stwE4o7btm5%2FlTVj5p%2F0Fm%2FU2%2Bv2sz4vaWYH%2FP5aqHczjCwqOSPpQjmF%2B4GD9OZDbY%2BbkxwoRIOzW7RjNRUpPkIpoL2Eqi6TEmtnK; _ga_FPD6YLJCJ7=GS1.1.1710515040.8.1.1710515057.43.0.0; aws-waf-token=95be0f53-92ae-444f-94c7-5e1cd5216bf0:DgoAg2NpjSp4AAAA:Ea17ttDwwytjfyYkwHre1VCRuAoTRaOGAClFFQq61kBOsZmc5b5QYkMbKHegQTDbJKnN9C4zSYTIWdBUECHQDwyHwkWkGOj6TL29q0aZvUeAwqwZxo9id53NOEyQRkqhp4vir1f31adENmGpGuQQWrBtgy59lPbKY0lxfHnlb4co0UfScngHxwMmvHvJpXqD2HnfXILS92GOxxt5r7fvWlV8clIdaILu8Z6D5rOQlvwJs121hDX6XcNAMobkFxG45/k=; lastSeen=0' 
                }
        )

        soup = get_html(req)

        data = soup.find('div', id = 'bodyconstraint-inner')
        number_of_results = find_num_results(data)
            
        properties_data = data.find('div', class_ = 'd4924c9e74')

        res_names = find_names(properties_data)
        names.extend(res_names)
        print('Names: ', len(names))

        res_full_prices, res_discount_prices, res_night_price, res_discount_p = find_prices(properties_data, nights)
        full_prices.extend(res_full_prices)
        discount_prices.extend(res_discount_prices)
        night_price.extend(res_night_price)
        discount_p.extend(res_discount_p)
        print('Full: ', len(full_prices))
        print('Discount:', len(discount_prices))
        print('Night price: ', len(night_price))
        print('discount p: ', len(discount_p))

        res_ratings, res_number_of_reviews, res_location_ratings = find_ratings(properties_data)
        ratings.extend(res_ratings)
        number_of_reviews.extend(res_number_of_reviews)
        location_ratings.extend(res_location_ratings)
        print('ratings: ', len(ratings))
        print('n ratings: ', len(number_of_reviews))
        print('locrat: ', len(location_ratings))

        res_stars = find_stars(properties_data)
        stars.extend(res_stars)
        print('stars: ', len(stars))

        res_distance = find_dist(properties_data)
        distance.extend(res_distance)
        print('dist: ', len(distance))

        res_genius, res_pref_partner, res_featured = find_programmes(properties_data)
        genius.extend(res_genius)
        pref_partner.extend(res_pref_partner)
        featured.extend(res_featured)
        print('genius: ', len(genius))
        print('pref_partner: ', len(pref_partner))
        print('featured: ', len(featured))

        res_free_cancellation, res_pay_later, res_breakfast_inc = find_policies(properties_data)
        free_cancellation.extend(res_free_cancellation)
        pay_later.extend(res_pay_later)
        breakfast_inc.extend(res_breakfast_inc)
        print('free canc: ', len(free_cancellation))
        print('brak: ', len(breakfast_inc))
        print('pay later: ', len(pay_later))

        res_deal, res_deal_type = find_deal(properties_data)
        deal.extend(res_deal)
        deal_type.extend(res_deal_type)
        print('deal: ', len(deal))
        print('deal typr: ', len(deal_type))


        res_new_prop = find_newprop(properties_data)
        new_prop.extend(res_new_prop)
        print('new prop: ', len(new_prop))

        res_travel_sustainability = find_trav_sustainability(properties_data)
        travel_sustainability.extend(res_travel_sustainability)
        print('trav sust: ', len(travel_sustainability))


        res_rent_type = find_rental_type(properties_data) 
        rental_type.extend(res_rent_type)
        print('rent type: ', len(rental_type))
        

        #res_room_type = find_rent_types(properties_data)
        #room_type.extend(res_room_type)
        #print('room type: ', len(room_type))

    rank2 = [i for i in range(1, len(names) + 1)]
    print(len(rank2))

    data = [rank2, night_price, discount_prices, full_prices, discount_p, ratings, number_of_reviews, location_ratings, genius, pref_partner, featured, deal, deal_type, distance, stars, free_cancellation, breakfast_inc, pay_later, travel_sustainability, new_prop]#, rental_type]
    
    df = create_df(data, names, filename, cause)

    return(number_of_results, df)

number_of_results, datum = start()
    
