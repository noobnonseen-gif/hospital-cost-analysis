import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('data/hospital_cost.csv')

print(df.head())
print(df.columns)

# Calculate average charges by smoking status (mean)
average_charges = df.groupby("smoker")["charges"].mean()
plt.figure()
ax_mean = average_charges.plot (kind="bar")

ax_mean.bar_label(
    ax_mean.containers[0],
    fmt="%.0f",
    label_type="center",
    color="white",
    fontweight="bold",
)

plt.title(
    "Average Healthcare Charges by Smoker Status",
    fontweight="bold"
)
plt.xlabel("Smoking Status")
plt.ylabel("Average Charges")
plt.xticks(rotation=45)
plt.tight_layout()

#Calculate average charges by smoking status (median)
median_charges = df.groupby("smoker")["charges"].median()
plt.figure()

ax_median = median_charges.plot (kind="bar")

ax_median.bar_label(
    ax_median.containers[0],
    fmt="%.0f",
    label_type="center",
    color="white",
    fontweight="bold",
)

plt.title("Median Healthcare Charges by Smoking Status",
          fontweight="bold")
plt.xlabel("Smoking Status")
plt.ylabel("Median Charges")
plt.xticks(rotation=45)
plt.tight_layout()

## Stacked Histogram by Smoking Status
plt.figure()

no_charges = df[df["smoker"] == "no"]["charges"]
yes_charges = df[df["smoker"] == "yes"]["charges"]

plt.hist(
    [no_charges, yes_charges],
    bins=30,
    stacked=True,
    label=["No", "Yes"],
    color=["blue", "red"]
)

plt.title(
    "Distribution of Healthcare Charges",
    fontweight="bold"
)
plt.xlabel("Healthcare Charges")
plt.ylabel("Frequency")
plt.legend(title="Smoking Status")
plt.tight_layout()

## Box Plot Healthcare Charges by Smoking Status

no_smoker_charges = df[df["smoker"] == "no"]["charges"]
yes_smoker_charges = df[df["smoker"] == "yes"]["charges"]

plt.figure()

plt.boxplot(
    [no_smoker_charges, yes_smoker_charges],
    tick_labels=["No", "Yes"],
    ## Sử dụng whis 2.5 IQR nhằm giảm sự rối mắt do các ngoại lệ phát sinh
    whis=2.5
)
plt.title(
    "Healthcare Charges by Smoking Status",
    fontweight="bold"
)
plt.xlabel("Smoking Status")
plt.ylabel("Healthcare Charges")
plt.tight_layout()

plt.show()