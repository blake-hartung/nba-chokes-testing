import pandas as pd

df1 = pd.read_csv("choke_list_1920.csv")
df2 = pd.read_csv("choke_list_2021.csv")
df3 = pd.read_csv("choke_list_2122.csv")
df4 = pd.read_csv("choke_list_171819.csv")

df = df1.append(df2, ignore_index=True)
df = df.append(df3, ignore_index=True)
df = df.append(df4, ignore_index=True).reset_index().drop(columns=['index'])

df.to_csv("choke_list_full.csv", index=False)