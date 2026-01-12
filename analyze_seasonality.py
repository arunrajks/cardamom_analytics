import pandas as pd
import calendar

def analyze_seasonality():
    try:
        print("Loading data...")
        # Load the data
        df = pd.read_csv('assets/historical_data.csv')
        print(f"Loaded {len(df)} records.")
        
        # Convert date column to datetime
        # Format is DD-MM-YYYY
        df['date'] = pd.to_datetime(df['auction_date'], format='%d-%m-%Y')
        
        # Extract month
        df['month'] = df['date'].dt.month
        
        # Calculate mean price per month
        # avg_price_per_kg is index 6
        monthly_avg = df.groupby('month')['avg_price_per_kg'].mean()
        
        print("--- Monthly Average Prices (All Time) ---")
        for month, price in monthly_avg.items():
            print(f"{calendar.month_name[month]}: ₹{price:.2f}")
            
        # Overall average for comparison
        overall_avg = monthly_avg.mean()
        print(f"\nOverall Average: ₹{overall_avg:.2f}")
        
        # Identify high months (> 5% above average)
        high_months = monthly_avg[monthly_avg > overall_avg * 1.05].index.tolist()
        low_months = monthly_avg[monthly_avg < overall_avg * 0.95].index.tolist()
        
        print("\nHistorically Strong Months (Sell Opportunity):")
        for m in high_months:
            print(f"- {calendar.month_name[m]}")
            
        print("\nHistorically Weak Months (Caution):")
        for m in low_months:
            print(f"- {calendar.month_name[m]}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    analyze_seasonality()
