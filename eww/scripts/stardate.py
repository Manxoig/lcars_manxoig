#!/usr/bin/env python3
import datetime
import sys

def main():
    try:
        now = datetime.datetime.now()
        year = now.year
        # Day of the year (1-366)
        day_of_year = now.timetuple().tm_yday
        # Hour and minute as fraction of day
        hour_frac = now.hour / 24.0 + now.minute / 1440.0
        
        # TNG-style stardate calculation:
        # (current_year - 1900) * 1000 + (day_of_year + hour_frac) * (1000 / 365.25)
        stardate = (year - 1900) * 1000 + (day_of_year + hour_frac) * (1000.0 / 365.25)
        print(f"{stardate:.1f}")
    except Exception as e:
        print("47915.6")  # Fallback to a classic Stardate if anything fails

if __name__ == "__main__":
    main()
