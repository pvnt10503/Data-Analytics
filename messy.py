import pandas as pd
from datetime import date
from datetime import datetime

df = pd.read_excel('D:/mythings/messy.xlsx',sheet_name = 'test')
df.columns = df.columns.str.lower()
df = df.drop('unnamed: 2', axis = 1)
df.columns = df.columns.str.replace('%', '')
df.columns = df.columns.str.replace(' ','')
#df.columns = ['cust_id','join_date','phone','full_name']
#create a list and assign it to columns
df.rename(columns={'custid':'cust_id','joindate':'join_date','mobiles':'phone','fllnam':'full_name'}, inplace = True)
#create a dictionary and assign it to columns, after that, use RENAME function
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
#change the format to the titlte

email_arr2 =[]
for i in range(len(df)):
    split_name = df['full_name'][i].split()
    lst_name = split_name[0]
    fst_name = split_name[1]
    id1 = str(df['cust_id'][i])
    email = '{last_name}.{first_name}.{id}@yourcompany.com'.format(last_name =lst_name,first_name = fst_name,id=id1)
#==== option 2
    #email = '%s.%s.%s@yourcompany.com'%(lst_name,frst_name,id1)
    email_arr2.append(email)
df['email2'] = email_arr2

df['phone'] = df['phone'].astype(str)
df['phone'] = df['phone'].apply(lambda x: x if x.startswith('84') else '84'+x)

df_idDup = df[df['cust_id'].duplicated()]
df = df.drop_duplicates(subset = 'cust_id',keep = 'first')
df