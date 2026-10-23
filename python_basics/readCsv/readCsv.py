import pandas as pd

# 1. Read CSV
df = pd.read_csv('test.csv')

print(f"Rows: {len(df)}")
print(f"Columns: {list(df.columns)}")

# 2. Add total column
df['total'] = df['qty'] * df['price']

print("\nFull data with total:")
print(df)

# 3. Top 3 by total
top_three = df.sort_values(by='total', ascending=False).head(3)

print("\nTop 3 orders:")
print(top_three)

# 4. Save without row numbers
# index=False removes the 0,1,2 row numbers from the CSV
top_three.to_csv('test2.csv', index=False)

print("\n✓ Saved top_three to test2.csv")

# 5. Verify saved file
verify = pd.read_csv('test2.csv')
print(f"\nVerification — rows in test2.csv: {len(verify)}")
print(verify)
