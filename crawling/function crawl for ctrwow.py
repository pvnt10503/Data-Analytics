import requests
import datetime
import pandas as pd
import csv
import numpy as np
import re


def fetch_ctrwow_data(startdate
                      ,enddate
                      ,token 
                      ,flowid 
                    ,pageId_start, pageId_end
                    , flow_start,flow_next
                    , domain
                    ):
    df_reorder_all = pd.DataFrame()
    # Get today's date in ISO format
    # token = "Token" 
    # date_str = startdate.strftime("%Y-%m-%d")  # Format to YYYY-MM-DD
    # date_str = enddate.strftime ("%Y-%m-%d")
    while startdate < enddate:
        date_str = startdate.strftime("%Y-%m-%d")  # Format to YYYY-MM-DD
        #date_str_1 = enddate.strftime ("%Y-%m-%d")
        start_date = f"{date_str}T00:00:00.000Z"
        end_date = f"{date_str}T23:59:59.999Z"

        url = (
    f'https://api.ctrwow.com/reporting/behaviorflows/{flowid}/'
    f'flows?siteId={flowid}&fromSiteId={flowid}&toSiteId={flowid}&'
    f'fromPageId={pageId_start}&toPageId={pageId_end}&'
    f'fromPageUrl=https%3A%2F%2Fwww.{domain}%2Fen%2F{flow_start}.html&toPageUrl=https%3A%2F%2Fwww.{domain}%2Fen%2F{flow_next}.html&'
    f'startDate={start_date}&endDate={end_date}'
        '&interactionOrder=1&maxSteps=5&minSessions=10&segment=0'
        )

        headers = {
            'accept': '*/*',
            'authorization': 'Bearer 'f'{token}',  # Replace with your valid token
            'content-type': 'application/json',
            'origin': 'https://www.ctrwow.com',
            'referer': 'https://www.ctrwow.com/',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',
            'x-language': 'en'
        }


        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            data = response.json()
            # print(data)
            records = []


            # Iterate through the JSON structure
            for flow in data:
                nodes = flow.get("data", {}).get("nodes", [])
                for node in nodes:
                    # Flatten each node and add to records
                    records.append(node)
            if not records:
                print(f"No data for {date_str}")
                startdate += datetime.timedelta(days=1)
                continue

            # Convert to DataFrame
            df = pd.DataFrame(records)
            df = df.drop_duplicates()
            
            # De-duplicate the DataFrame
            # Define the regex pattern
            pattern = r"(index|order|pre)[^/]*\.html$"


            df['date'] = startdate
            



            # Apply filter on both 'from_pageUrl' and 'to_pageUrl'
            filtered_df = df[
                df["pageUrl"].str.contains(pattern, regex=True, na=False)
            ]
            filtered_df['flow'] = flow_start
            
                

        except requests.RequestException as e:
            print("Request failed:", e)
        sorted_filtered_df = filtered_df.sort_values('sessions',ascending=False).drop_duplicates('pageUrl',keep='first')
        sorted_filtered_df = sorted_filtered_df.reset_index(drop=True)
                

        df_reorder = sorted_filtered_df[['date','pageUrl','sessions','conversions','flow']]

        
        df_reorder_all = pd.concat([df_reorder_all,df_reorder],ignore_index=True)  


            
        startdate += datetime.timedelta(days=1)
        if startdate == enddate:
            break
    return df_reorder_all


import re

def click_thrus(df):
    df['click_thrus'] = 0
    rows_to_drop = []

    for i in range(len(df)):
        current_flow = df.loc[i, 'flow']
        current_date = df.loc[i, 'date']
        current_sessions = df.loc[i, 'sessions']
        current_page = df.loc[i, 'pageUrl']

        # --- Rule 1: Set click_thrus = 0 for checkout pages
        if re.search(r"order[^/]*\.html", current_page):
            df.at[i, 'click_thrus'] = 0
            continue

        # --- Rule 2: Handle index-based flows
        if re.search(r"^index", current_flow, flags=re.IGNORECASE):
            # Drop all non-index and non-checkout pages
            if not re.search(r"(index|order)[^/]*\.html$", current_page, flags=re.IGNORECASE):
                rows_to_drop.append(i)
                continue

            # Handle duplicate index.html across all flows starting with 'index'
            if re.search(r"index[^/]*\.html$", current_page):
                # Group all index flows on the same date
                same_index_group = df[
                    df['flow'].str.startswith("index") &
                    (df['date'] == current_date) &
                    df['pageUrl'].str.contains(r"index[^/]*\.html$", regex=True)
                ]
                indices = same_index_group.index.tolist()
                if i in indices[1:]:  # Keep only the first
                    rows_to_drop.append(i)
                    continue

                # Sum sessions from all order pages for same date and index-based flows
                order_pages = df[
                    df['flow'].str.startswith("index") &
                    (df['date'] == current_date) &
                    df['pageUrl'].str.contains(r"order[^/]*\.html$", regex=True)
                ]
                total_order_sessions = order_pages['sessions'].sum()
                df.at[i, 'click_thrus'] = total_order_sessions

        else:
            # --- Rule 3: Pre flow default behavior
            next_rows = df.loc[i+1:]
            same_flow_date = next_rows[
                (next_rows['flow'] == current_flow) &
                (next_rows['date'] == current_date)
            ]
            if same_flow_date.empty:
                continue

            first_next = same_flow_date.iloc[0]
            if first_next['sessions'] < current_sessions:
                df.at[i, 'click_thrus'] = first_next['sessions']

            # Add order page sessions if any
            order_pages = same_flow_date[
                same_flow_date['pageUrl'].str.contains(r"order[^/]*\.html$", regex=True)
            ]
            if not order_pages.empty:
                order_sum = order_pages['sessions'].sum()
                if order_sum > df.at[i, 'click_thrus']:
                    df.at[i, 'click_thrus'] = order_sum

    # Drop marked rows
    if rows_to_drop:
        df.drop(index=rows_to_drop, inplace=True)
        df.reset_index(drop=True, inplace=True)
    
    return df
