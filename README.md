# Booking-Crawler

## Booking.com Web Crawler
This Python script serves as a web crawler designed specifically for Booking.com. It gathers data about accommodation listings in a given destination and stores them in a structured format for further analysis or processing.

### Features
Data Collection: Scrapes data from Booking.com search result pages including property names, prices, ratings, reviews, and more.
Customizable: Users can specify various parameters such as check-in and check-out dates, number of adults and children, and number of pages to scrape.
Filtering: Allows users to apply filters such as distance, review score, property type, and more.
Data Export: Saves the collected data into a structured format such as a CSV file for easy analysis.

### Technologies Used
Python: The core programming language used for writing the web crawler.
Beautiful Soup: A Python library for pulling data out of HTML and XML files. Used for parsing HTML content scraped from Booking.com.
urllib: A Python library for opening URLs. Used for making HTTP requests to Booking.com.
pandas: A powerful data manipulation and analysis library for Python. Used for creating and manipulating data frames.
numpy: A fundamental package for scientific computing with Python. Used for numerical operations on data.
Regular Expressions (re): Used for pattern matching and extracting specific data from HTML content.

### Usage
Setup Environment: Ensure you have Python installed on your system.
Install Dependencies: Run pip install beautifulsoup4 pandas numpy.
Clone Repository: Clone this repository to your local machine.
Run the Script: Execute the Python script booking_crawler.py and follow the prompts to specify search parameters and filters.
Retrieve Data: After the script completes execution, the collected data will be saved in the specified file format (e.g., CSV) in the output directory.

### Note
The code may not be functional because the html has been slightly modified by Booking.
Please read terms and services on the booking.com website before using this code.
