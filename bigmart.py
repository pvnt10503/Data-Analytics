from matplotlib import pyplot as plt
import pandas as pd
import seaborn as sns
train = pd.read_csv('D:/mythings/train.csv')
test = pd.read_csv('D:/mythings/test.csv')


train.head()
train.Item_Type.value_counts()
train.shape
train.info()
#use the argument include='all' to see the descriptive stats about all types of variables
train.describe(include='all') 
#get the number of missing datapoints per column
train.isnull().sum().sort_values(ascending=False)
sns.jointplot(data = train, x = 'Item_Weight', y='Item_Outlet_Sales')
train['Outlet_Establishment_Year'].value_counts()
train['Item_Type'].value_counts()

test.head()
test.shape
test.info()

numeric_cols = train.select_dtypes(include=['float64','int64']).columns.to_list()
numeric_cols
#DataFrame.describe().T will transpose 
# ['count','mean','std','min','max','25%','50%','75%']
# from indexes to columns
train.describe().T

_, ax = plt.subplots(nrows=1, ncols=5, figsize=(26, 4))
for index, col in enumerate(numeric_cols):
    sns.displot(data = train[col], kde = False, ax = ax[index])
    ax[index].set_title(f'{col} distribution')

_, ax = plt.subplots(nrows = 1, ncols = 5, figsize = (26,4))
for index, col in enumerate(numeric_cols):
    sns.kdeplot(data = train, x = col, ax = ax[index])
    ax[index].set_title(f'{col} distribution in Train')

#Comparing with Train data, there is no differnece in the distribution between Train and Test
_, ax = plt.subplots(nrows = 1 , ncols = 4, figsize = (26,4))
for index, col in enumerate(['Item_Weight','Item_Visibility','Item_MRP','Outlet_Establishment_Year']):
    sns.displot(data = test[col], kde = True, ax = ax[index])
    ax[index].set_title(f'{col} distribution in Test')

# identify which cols have outliers.
# it is clearly to see that outliers are in Item_Visibility and Item_Outlet_Sales
_, ax = plt.subplots(nrows = 1, ncols = 5, figsize=(26,4))
for index, col in enumerate(numeric_cols):
    sns.boxplot(data = train, y = col, ax = ax[index])
    ax[index].set_title(f'{col} distribution')

_, ax = plt.subplots(nrows = 1, ncols = 5 , figsize = ( 26,8))
for index, col in enumerate(numeric_cols):
    sns.violinplot(data = train, y = col, ax = ax[index], inner = 'quartile')
    ax[index].set_title(f'{col} distribution')

categorical_cols = train.select_dtypes(include='object').columns.to_list()
categorical_cols


categorical_to_display = [
    'Item_Fat_Content','Item_Type','Outlet_Size','Outlet_Location_Type','Outlet_Type'
    ]
for col in categorical_to_display:
    print(f'Number of values in the {col} column is :\n{train[col].value_counts()}')
    print('--'*30)

train['Outlet_Location_Type'].unique().tolist()