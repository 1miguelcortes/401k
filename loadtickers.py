import requests
import pandas as pd
from bs4 import BeautifulSoup

def parse_html_table(table):
    n_columns = 0
    n_rows=0
    column_names = []

    # Find number of rows and columns
    # we also find the column titles if we can
    for row in table.find_all('tr'):
        
        # Determine the number of rows in the table
        td_tags = row.find_all('td')
        if len(td_tags) > 0:
            n_rows+=1
            if n_columns == 0:
                # Set the number of columns for our table
                n_columns = len(td_tags)
                
        # Handle column names if we find them
        th_tags = row.find_all('th') 
        if len(th_tags) > 0 and len(column_names) == 0:
            for th in th_tags:
                column_names.append(th.get_text())

    # Safeguard on Column Titles
    if len(column_names) > 0 and len(column_names) != n_columns:
        raise Exception("Column titles do not match the number of columns")

    columns = column_names if len(column_names) > 0 else range(0,n_columns)
    df = pd.DataFrame(columns = columns,
                      index= range(0,n_rows))
    row_marker = 0
    for row in table.find_all('tr'):
        column_marker = 0
        columns = row.find_all('td')
        for column in columns:
            df.iat[row_marker,column_marker] = column.get_text()
            column_marker += 1
        if len(columns) > 0:
            row_marker += 1
            
    # Convert to float if possible
    for col in df:
        try:
            df[col] = df[col].astype(float)
        except ValueError:
            pass
    
    return df


# Make the GET request to a url
DOW30 = "https://en.wikipedia.org/wiki/Dow_Jones_Industrial_Average"
r = requests.get(DOW30)
# Extract the content
c = r.content
#print(c)

# Create a soup object
soup = BeautifulSoup(c)
# Find the element on the webpage
#main_content = soup.find('div', attrs = {'class': 'entry-content'})
# Extract the relevant information as text
#content = main_content.find('ul').text
# Create a pattern to match names
#name_pattern = re.compile(r'^([A-Z]{1}.+?)(?:,)', flags = re.M)
# Find all occurrences of the pattern
#names = name_pattern.findall(content)


htable = soup.find('table', {'class': 'wikitable sortable'})
#print(htable)

df = parse_html_table(htable)
print(df.head())

df.to_csv("csv/dow30.csv", index=False)

SP500 = "http://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
r = requests.get(SP500)
# Extract the content
c = r.content
#print(c)

# Create a soup object
soup = BeautifulSoup(c)
# Find the element on the webpage
#main_content = soup.find('div', attrs = {'class': 'entry-content'})
# Extract the relevant information as text
#content = main_content.find('ul').text
# Create a pattern to match names
#name_pattern = re.compile(r'^([A-Z]{1}.+?)(?:,)', flags = re.M)
# Find all occurrences of the pattern
#names = name_pattern.findall(content)


htable = soup.find('table', {'class': 'wikitable sortable'})
#print(htable)

df = parse_html_table(htable)
print(df.head())

df.to_csv("csv/sp500.csv", index=False)

