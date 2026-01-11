import csv
import math
from collections import defaultdict

def calculate_stability(file_path, month_year):
    daily_prices = defaultdict(list)
    
    with open(file_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            date_str = row['auction_date']
            if month_year in date_str:
                try:
                    price = float(row['avg_price_per_kg'])
                    daily_prices[date_str].append(price)
                except ValueError:
                    continue
                    
    if not daily_prices:
        print("No data found for the specified period.")
        return

    # 1. Calculate daily averages
    daily_avgs = []
    for date, prices in daily_prices.items():
        daily_avgs.append(sum(prices) / len(prices))
        
    # 2. Calculate Standard Deviation (Stability)
    n = len(daily_avgs)
    if n < 2:
        print(f"Not enough data days ({n}) to calculate stability.")
        return
        
    mean = sum(daily_avgs) / n
    variance = sum((x - mean) ** 2 for x in daily_avgs) / n
    std_dev = math.sqrt(variance)
    
    print(f"Results for {month_year}:")
    print(f"Total auction days: {n}")
    print(f"Mean Price: ₹{mean:.2f}")
    print(f"Stability Level (Std Dev): ± ₹{std_dev:.2f}")
    print(f"Price Range: ₹{min(daily_avgs):.2f} - ₹{max(daily_avgs):.2f}")

if __name__ == "__main__":
    calculate_stability('assets/historical_data.csv', '-12-2025')
