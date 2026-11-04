import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('data/hospital_cost.csv')

print(df.head())
print(df.columns)

# Calculate average charges by smoking status
average_charges = df.groupby("smoker")["charges"].mean()
plt.figure()
average_charges.plot (kind="bar")

plt.title(
    "Average Healthcare Charges by Smoker Status",
    fontweight="bold"
)
plt.xlabel("Smoking Status")
plt.ylabel("Average Charges")
plt.xticks(rotation=45)
plt.tight_layout()
