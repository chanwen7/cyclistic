# Cyclistic Bike-share Data Analysis project

### What is this repo?
This repo contains my capstone project for the Google Data Analytics Course, which is an exercise of the data analytics skills I learnt from the course.

In this project, I will be utilizing the Google's process of data analytics to solve a business scenario, of a bike-share company's strategy to convert casual riders into annual members of its bike-share program.

**SQL** and **R** have been chosen as tools used for this project, with this Markdown document as the project report accompanied by a Microsoft PowerPoint slide deck.
At a later date, a dashboard extension of the project will be available on **Tableau** as well.


## Introduction
### Project background
#### The story of Cyclistic
Cyclistic is a successful bike-share offering launched in 2016. The program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago.

Cyclistic's marketing strategy to-date relied largely on building general awareness and appealing to the broad consumer base. One such approach is the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as *casual riders*, and those who purchase annual memberships as *Cyclistic members*.

#### A new strategy
Over time, Cyclistic’s finance analysts have concluded that annual members are much more profitable than casual riders. The marketing director, Lily Moreno, believes that maximizing the number of annual members will be key to future growth. Rather than a marketing campaign targeting all-new customers, Moreno believes there's a solid opportunity to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.

#### Project stakeholders
We play the role of a junior data analyst working on the marketing analyst team at Cyclistic, to utilize data in support of Cyclistic's new strategy.

The stakeholders for this project include **Lily Moreno**, the director of marketing and our manager, responsible for the development of campaigns and initiatives promoting Cyclistic, the **Cyclistic marketing analytics team**, responsible for collecting/analyzing/reporting data to guide Cyclistic's marketing strategy, and the **Cyclistic executive team**, a detail-oriented executive team deciding whether to approve the recommended marketing program.

### Business problem and tasks
Our goal is to convert Cyclistic's casual riders into annual members, thereby ensuring longer-term profits.

We can break this problem down into multiple key questions as follows, serving as guideposts for our data analysis:
	1. How do annual members and casual riders use Cyclistic bikes differently?
	2. Why would casual riders buy Cyclistic annual memberships?
  3. How can Cyclistic use digital media to influence casual riders to become members?


## Data cleaning and processing
### Dataset
I will be using Cyclistic bike share data from the past 12 months (July 2023 to June 2024) provided by the Google Data Analytics Course. This dataset is in comma-separated value format (.csv), and is emulated from an actual bike-share company operating in Chicago, USA: Lyft Bikes and Scooters, LLC (“Bikeshare”), under the [respective license](https://divvy-tripdata.s3.amazonaws.com/index.html). Data from each calendar month is stored in its own .csv file.

The raw dataset (.csv) can be viewed [here](link to file).

Due to privacy issues, the personal & identifiable information of riders are not used. This means that some important data such as purchase history of individual riders and their demographics cannot be explored in the scope of this project.

