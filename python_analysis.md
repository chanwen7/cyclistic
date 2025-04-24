#### The following is a redo of the **Data Analysis** section of the report, using Pandas and other relevant packages from Python.

The rest of the report is available at the following [link](https://github.com/chanwen7/cyclistic/blob/main/README.md).

## Data analysis
Data analysis is performed using R, within the RStudio interface. Appropriate R extensions are utilized, namely the tidyverse package for data analysis.

We will be looking at analysis for the following, for both annual members and casual riders, comparing the two groups where appropriate:
	1. Total trips taken by month, day of week, and start time
	2. Types of bicycles used
	3. Length of trips
	4. Location of stations used

We work with the assumption that our cleaned data represents the overall customer base well (including those omitted from cleaning).

How do annual members and casual riders use Cyclistic bikes differently?
Why would casual riders buy Cyclistic annual memberships?
How can Cyclistic use digital media to influence casual riders to become members?


##### Setting up the environment
Python 3.13 is utilized for data analysis, using the PyCharm 2025.1 interface.
Packages used includes Pandas, Matplotlib (pyplot), and Seaborn.
Cleaned data  was imported via Pandas into a dataframe.
```
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

bikeshare = pd.read_csv('C:/Users/Admin/Desktop/Coding/_Google Data Analytics Course/Course 8 - Capstone project/Data/bikeshare_data.csv')
```

Some additional setup for formatting of our visualizations were also performed.
```
# Set plot style and palette
plt.style.use('bmh')
ggplot_hex = ['#F8766D', '#619CFF']
type_palette = {'casual': ggplot_hex[0], 'member': ggplot_hex[1]}

# Define common formatting for plot axes objects
def format_plot(axes):
    for label in axes.get_xticklabels():
        label.set_alpha(0.65)
    for label in axes.get_yticklabels():
        label.set_alpha(0.65)
    axes.grid(False)
    axes.tick_params(bottom=False)
    sns.despine()
```


### Is the casual rider customer base worth converting?

We first count the number of rides by both casual riders and annual members. The code below provides us with a bar chart of the number and percentage of rides by each customer time.

```
## Ride count per customer type
bikeshare_typecount = bikeshare.value_counts('customer_type').reset_index()
bikeshare_typecount['prop'] = bikeshare_typecount['count']*100 / bikeshare_typecount['count'].sum()
bikeshare_typecount.sort_values('customer_type', inplace=True)
bikeshare_typecount.reset_index(drop=True, inplace=True)


# Visualization
fig, ax = plt.subplots()
sns.barplot(bikeshare_typecount, x='customer_type', y='prop', order=['casual', 'member'], hue='customer_type', palette=type_palette)

ax.set_title('Number of rides by Customer type', weight='semibold')
ax.set(xlabel='Customer Type', ylabel='Percentage of rides (%)')
ax.set_xticks(['casual', 'member'], ['Casual rider', 'Annual member'])

for row in bikeshare_typecount.iterrows():
    label = str(row[1]['count'])
    x_pos = row[0]
    y_pos = row[1]['prop'] - 4
    ax.text(s=label, x=x_pos, y=y_pos, ha='center')

format_plot(ax)

plt.show()
plt.clf()
```
![chart_1](https://github.com/chanwen7/cyclistic/blob/main/charts/python%201_customer%20type%20count.png)

Casual riders make up **34.7% (n = 1470287)** of all total rides, while annual members make up **65.3% (n = 2770571)**. This shows that there is indeed a large population Cyclistic can target our marketing efforts to.

If the number of unique casual riders outweigh number of unique annual members, we can also infer annual members are likely to utilize a larger number of rides per person, indicating an opportunity for greater earnings if our large casual rider base can become converted to annual members. This is of course an assumption, given that we are not provided personal rider information in this project.


### Analysis of trips over time

Analysis of when bike rides take place provides insights on behavioral patterns of Cyclistic casual riders and annual members. Bike ride data is analyzed across each month, day of the week, and start time of the day.

### Trips made per month

We break down rides taken each month across both casual riders and annual members, using bar charts to illustrate distribution of rides. Percentage of rides (within each group) are used instead of ride counts, to allow easier side-by-side comparison of both groups.
```
## Trips made each month (proportioned within customer type group)
bikeshare_month = bikeshare.groupby(['customer_type', 'month']).size()
bikeshare_month = bikeshare_month.unstack(level='customer_type').reset_index()
bikeshare_month['casual_pct'] = round(bikeshare_month['casual']*100 / sum(bikeshare_month['casual']), 2)
bikeshare_month['member_pct'] = round(bikeshare_month['member']*100 / sum(bikeshare_month['member']), 2)


# Visualization
fig, (ax_casual, ax_member) = plt.subplots(1, 2, sharey=True, tight_layout=True)
sns.barplot(bikeshare_month, x='month', y='casual_pct', ax=ax_casual, color=ggplot_hex[0])
sns.barplot(bikeshare_month, x='month', y='member_pct', ax=ax_member, color=ggplot_hex[1])

fig.supxlabel('Month', size=13)
ax_casual.set(ylabel='Percentage of rides (%) within group', xlabel=None)
ax_member.set(xlabel=None)
fig.suptitle('Percentage of rides over each month', size=14, weight='bold')
ax_casual.set_title('Casual rider', size=12, weight='semibold', alpha=0.9)
ax_member.set_title('Annual member', size=12, weight='semibold', alpha=0.9)

format_plot(ax_casual)
format_plot(ax_member)

import calendar
def month_label(axes, col):      # x-axis tick label creation, for each month in 3-letter abbreviation
    top_month = bikeshare_month.loc[bikeshare_month[col].idxmax(), 'month']
    top_month_abbr = calendar.month_abbr[top_month]
    axes.text(top_month-1.5, max(bikeshare_month[col])+0.2, top_month_abbr)

month_label(ax_casual, 'casual_pct')
month_label(ax_member, 'member_pct')

plt.show()
plt.clf()
```
![chart_2a](https://github.com/chanwen7/cyclistic/blob/main/charts/python%202_trips%20by%20month.png)

We see that peak periods are relatively similar between both customer types, with **July** being the most popular month at **15.5%** for rides amongst casual riders, while **August** is the most popular month at **12.7%** for annual members.

Casual riders preference for summer months appear to be more pronounced that that of annual members, with higher peak and lower trough in proportion of rides.


### Trips made each day of the week

Next, we break down rides taken each day of the week across both customer types, using a grouped bar chart to illustrate distribution of rides.
```
## Trips made each day of the week, by customer type
dow_labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

bikeshare_dow = bikeshare.groupby(['customer_type', 'day_of_week']).size().reset_index()
bikeshare_dow.columns = ['customer_type', 'day_of_week', 'ride_count']
bikeshare_dow['dow_letter'] = bikeshare_dow['day_of_week'].map(lambda x: dow_labels[x])
bikeshare_dow['dow_letter'] = pd.Categorical(bikeshare_dow['dow_letter'], categories=dow_labels, ordered=True)


# Visualization
fig, ax = plt.subplots()
sns.barplot(bikeshare_dow, x='dow_letter', y='ride_count', hue='customer_type', palette=type_palette)

ax.set_title('Number of rides over each day of the week', weight='semibold', size=13)
ax.set_xlabel('Day of the week', size=13)
ax.set_ylabel('Number of rides', size=13)

from matplotlib.font_manager import FontProperties

handles, labels = ax.get_legend_handles_labels()
legend = ax.legend(handles, ['Casual rider', 'Annual member'], title='Customer type', framealpha=0.3)
legend.get_title().set_weight('bold')

format_plot(ax)

plt.tight_layout()
plt.show()
```
![chart_3](https://github.com/chanwen7/cyclistic/blob/main/charts/python%203_trips%20by%20dow.png)

For casual riders, **38.5%** of rides take place over weekends, and **61.5%** over weekdays.
For annual riders, **24.0%** of rides take place over weekends, and **76.0%** over weekdays.

We see that there's a clear preference for rides over the weekend amongst casual riders, , while annual members prefer riding during the weekdays.

This could indicate a difference in purpose of bike trips between both customer groups, with annual members perhaps using it as a form of commuting between home and workplace, whereas casual riders do so for weekend leisure activities.


### Starting time of trips

Finally, we can analyze the start time of each trip across both customer types.
```
## Rides by start time of ride (per customer type)
bikeshare['started_at'] = bikeshare['started_at'].str[:19]      # Remove milliseconds
bikeshare['started_at'] = pd.to_datetime(bikeshare['started_at'])
bikeshare['ended_at'] = bikeshare['ended_at'].str[:19]
bikeshare['ended_at'] = pd.to_datetime(bikeshare['ended_at'])

bikeshare['start_hour'] = bikeshare['started_at'].dt.hour + bikeshare['started_at'].dt.minute / 60

bikeshare['day_type'] = bikeshare['started_at'].dt.dayofweek.apply(lambda x: 'Weekday' if x < 5 else 'Weekend')


# Visualization
g = sns.FacetGrid(data=bikeshare, col='customer_type', col_order=['casual', 'member'],
                  hue='customer_type', palette=type_palette, height=4)
g.map_dataframe(func=sns.histplot, x='start_hour', bins=24, stat='percent')

g.fig.suptitle('Percentage of rides over Start time of ride', size=13, weight='bold')
g.axes[0, 0].set_title("Casual rider", size=10, weight='semibold', y=0.92)
g.axes[0, 1].set_title("Annual member", size=10, weight='semibold', y=0.92)
g.fig.supxlabel('Time of the day (h)', size=13)
g.fig.supylabel('Percentage of rides (%) within group', size=11)
g.set(xlabel='', ylabel='')

plt.xlim(left=-0.5, right=24.5)
format_plot(g.axes[0, 0])
format_plot(g.axes[0, 1])

plt.show()
plt.clf()
```
![chart_4a](https://github.com/chanwen7/cyclistic/blob/main/charts/python%204_start%20time%20of%20ride.png)

We see that amongst all riders, **peak activity occurs around 5-6pm**. This coincides with the end of the workday, where riders are likely to either cycle from workplace to home or to other locations.

However, there's a secondary peak of ride activity only amongst annual members, at **around 8am** in the morning, coinciding with the start of the workday.

This further supports our earlier hypothesis that annual members are likely to depend on bike sharing to commute to and from work. On the other hand, casual riders are at most commute from work to home, choosing to take alternative modes of transport at the start of the day.


As we noted earlier that casual riders prefer taking bicycles on weekends, I hence further analyzed these patterns of start time grouped by either weekday trips or weekend trips.
```
## Rides by start time of ride (per customer type, weekday vs weekend)

# Visualization
g = sns.FacetGrid(
    data=bikeshare, row='customer_type', col='day_type', row_order=['casual', 'member'], col_order=['Weekday', 'Weekend'],
    hue='customer_type', palette=type_palette, height=3.5)
g.map_dataframe(sns.histplot, x='start_hour', bins=24, stat='percent', color=None)

g.fig.suptitle('Percentage of rides over Start time of ride', size=13, weight='bold')
g.set_titles(row_template="{row_name} rider", col_template="{col_name}s")  # give titles like "Casual rider" and "Weekdays"
title_map = {
    ('casual', 'Weekday'): "Casual rider, Weekdays",
    ('casual', 'Weekend'): "Casual rider, Weekends",
    ('member', 'Weekday'): "Annual member, Weekdays",
    ('member', 'Weekend'): "Annual member, Weekends"}
for i, row_val in enumerate(['casual', 'member']):
    for j, col_val in enumerate(['Weekday', 'Weekend']):
        g.axes[i, j].set_title(title_map[(row_val, col_val)], size=10, weight='semibold', y=0.92)

g.fig.supxlabel('Time of the day (h)', size=13)
g.fig.supylabel('Percentage of rides (%) within group', size=13.5)
g.set(xlabel='', ylabel='')

plt.xlim(-0.5, 24.5)
for ax_row in g.axes:
    for ax in ax_row:
        format_plot(ax)

plt.show()
plt.clf()
```
![chart_4b](https://github.com/chanwen7/cyclistic/blob/main/charts/python%204b_start%20time%20weekend_day.png)

We see that for weekdays, a smaller proportion do so in the mornings as well. Proportion of the morning group amongst casual riders is roughly half that of annual members, and our previous inference that casual riders generally prefer other modes of transport at the start of the day is still logical.

On weekends, the distribution of rides appear to follow a gentler distribution, with a less pronounced peak that is spread across a larger time period of **12 to 5pm**. This patterns holds for both annual members and casual riders.


### Duration of trips

We can also analyze information about the duration of each ride by customer type. Due to a vast majority of ride durations being shorter, the range of ride durations displayed has been restricted to 0 to 3 hours.
```
## Distribution of duration of each trip, by customer type
bikeshare['duration_hr'] = (bikeshare['ended_at'] - bikeshare['started_at']).dt.total_seconds() / 3600
bikeshare_short = bikeshare[bikeshare['duration_hr'] <= 3]   # To only plot bike rides 3 hours or under
bikeshare_short_2 = bikeshare[(bikeshare['duration_hr'] >= 0.5) & (bikeshare['duration_hr'] <= 3)]

# Visualization
g = sns.FacetGrid(bikeshare_short, col='customer_type', sharey=True, col_order=['casual', 'member'],
    hue='customer_type', height=4, palette=type_palette)
g.map_dataframe(sns.histplot, x='duration_hr', bins=12, stat='percent')

plt.tight_layout(rect=[0, 0, 1, 0.95])
g.fig.suptitle('Percentage of rides over ride duration', size=14, weight='bold', x=0.08, ha='left')
g.fig.text(s='Up to 3 hours', size=12, x=0.08, y=0.88, ha='left')
g.set(xlabel='', ylabel='')
g.fig.supxlabel('Duration of ride (h)', size=13.5)
g.fig.supylabel('Percentage of rides (%) within group', size=11.5)

plt.xlim(-0.15, 3.15)

title_map = {'casual': 'Casual rider', 'member': 'Annual member'}
for ax, col in zip(g.axes.flat, g.col_names):
    ax.set_title(title_map[col], size=10, weight='semibold', y=0.92)
    format_plot(ax)

plt.show()
plt.clf()
```
![chart_5a](https://github.com/chanwen7/cyclistic/blob/main/charts/python%205_ride%20duration.png)

We see that regardless of customer type, a vast majority of customers prefer to take short rides under 1 hour.

However, the chart for casual riders appear to have a longer tail than that of annual members, where more casual riders prefer rides of around 30 minutes to 3 hours in length.


For the casual rider group, I further investigated ride duration over weekdays and weekends, excluding short rides under 30 minutes. This is an attempt to find out whether longer trip length is related to riding on weekends, where we can further make an inference of casual riders preferring cycling as a weekend leisure activity.
```
## Ride duration on weekdays & weekends, for casual riders (durations under 30 minutes omitted)
# Visualization
g = sns.FacetGrid(bikeshare_short_2, col='day_type', sharey=True, col_order=['Weekday', 'Weekend'],
    height=4)
g.map_dataframe(sns.histplot, x='duration_hr', bins=12, stat='percent', color=ggplot_hex[0])

plt.tight_layout(rect=[0, 0, 1, 0.95])
g.fig.suptitle('Percentage of rides over ride duration (casual riders)', size=14, weight='bold', x=0.08, ha='left')
g.fig.text(s='Between 30 minutes to 3 hours', size=12, x=0.08, y=0.88, ha='left')
g.set(xlabel='', ylabel='')
g.fig.supxlabel('Duration of ride (h)', size=13.5)
g.fig.supylabel('Percentage of rides (%) within group', size=11.5)

plt.xlim(0.35, 3.15)

for ax, col in zip(g.axes.flat, g.col_names):
    ax.set_title(col, size=10, weight='semibold', y=0.92)
    format_plot(ax)

plt.show()
plt.clf()
```
![chart_5b](https://github.com/chanwen7/cyclistic/blob/main/charts/python%205b_ride%20duration%20weekend_day.png)

Interestingly, we see that distribution of rides (by proportion) over weekdays and weekends for casual riders are similar for ride durations above 30 minutes (and under 3 hours).

This tells us that while casual riders have a greater tendency to cycle over the weekends, they don't necessarily do so for different purposes than on weekdays, at least based on the duration of their rides. There is hence less evidence to support the theory of casual riders preferring weekend cycling as a leisure activity.

An alternative reason for some casual riders preferring longer trips regardless of day of the week, could be that they simply have to commute greater distances, whether for work, leisure, or other daily activities. It might be the reason why they are not annual members in the first place, given that cycling is not the most convenient mode of transport with trips taking longer than they prefer.

The higher rates of cycling on the weekend could be due to an allowance of time for casual riders to more conveniently undertake these longer trips.


### Most commonly-used stations

The last category for our data analysis is to look at the most commonly-used bike stations, both at the start and end of each ride.

Code and diagram for the most common start stations are as follows:
```
## Most common stations rides started at (top 10)
top10_start = bikeshare['start_station_name'].value_counts().reset_index()
top10_start = top10_start.loc[:9, :]

# Visualization
fig, ax = plt.subplots()
sns.barplot(top10_start, x='count', y='start_station_name', hue='start_station_name', palette=palette_top10)

plt.tight_layout(rect=[-0.15, 0, 1, 0.9])
ax.set(xlabel='Number of rides', ylabel='')
ax.set_title('Top 10 bike stations by number of rides started', size=14, weight='bold', x=0, y=1.05, ha='left')
fig.text(s='For casual riders', size=12, x=0.31, y=0.88, ha='left')

plt.yticks(rotation=20, size=8, weight='light')

plt.show()
plt.clf()
```
![chart_6a](https://github.com/chanwen7/cyclistic/blob/main/charts/python%206a_top%2010%20start.png)

Code and diagram for the most common end stations are as follows:
```
## Most common stations rides ended at (top 10)
top10_end = bikeshare['end_station_name'].value_counts().reset_index()
top10_end = top10_end.loc[:9, :]

# Visualization
fig, ax = plt.subplots()
sns.barplot(top10_end, x='count', y='end_station_name', hue='end_station_name', palette=palette_top10)

plt.tight_layout(rect=[-0.15, 0, 1, 0.9])
ax.set(xlabel='Number of rides', ylabel='')
ax.set_title('Top 10 bike stations by number of rides ended', size=14, weight='bold', x=0, y=1.05, ha='left')
fig.text(s='For casual riders', size=12, x=0.31, y=0.88, ha='left')

plt.yticks(rotation=20, size=8, weight='light')

plt.show()
plt.clf()
```
![chart_6b](https://github.com/chanwen7/cyclistic/blob/main/charts/python%206b_top%2010%20end.png)

Many of these stations are both start and end points, representing the most popular destinations frequented by casual riders.
