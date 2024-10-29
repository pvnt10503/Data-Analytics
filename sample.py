import pandas as pd
df = pd.read_excel('D:/mythings/messy.xlsx',sheet_name = 'test')
df.head()
df = df.drop(columns = 'Unnamed: 2')
df.columns = df.columns.str.lower()
df.columns = df.columns.str.replace(' ','')
df.columns = df.columns.str.replace('%','')
df = df.rename(columns = {'custid': 'cust_id', 'joindate': 'join_date', 'mobiles': 'phones', 'fllnam': 'full_name'})

def split_date(x):
    s1 = x.split(' ')
    if len(s1) == 2:
        s2 = s1[0]
        return s2
    try:
        return x
    except:
        return None
df['join_date'] = df['join_date'].apply(split_date)
df['join_date'] = pd.to_datetime(df['join_date']).dt.date

df['full_name'] = df['full_name'].str.title()

email_arr = []
for i in range(len(df)):
    split_name = df['full_name'][i].split()
    last_name = split_name[0]
    first_name = split_name[1]
    id = str(df['cust_id'][i])
    email ='{last_name}.{first_name}.{id}@yourcompany.com'.format(last_name = last_name,first_name = first_name,id=id)
    email_arr.append(email)
df['email'] = email_arr

df['phones'] = df['phones'].astype(str)
df['phones'] = df['phones'].apply(lambda x: x if x.startswith('84') else '84'+x)
#df['cust_id'].duplicated() will test which index having cust_id duplicated, 
#df[df['cust_id'].duplicated()] to gather these duplicates into a dataframe name as df_idDup
df_idDup = df[df['cust_id'].duplicated()]

