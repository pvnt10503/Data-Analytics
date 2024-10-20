import pandas as pd
import matplotlib as plt
train = pd.read_csv('D:/mythings/train.csv')
train.head()
train.Item_Type.value_counts()
train.shape
train.info()
#use the argument include='all' to see the descriptive stats about all types of variables
train.describe(include='all') 
#get the number of missing datapoints per column
train.isnull().sum().sort_values(ascending=False)