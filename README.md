# UEFA_SQL_Project
SQL-based analysis of UEFA football data using PostgreSQL, exploring player performance, team statistics, match outcomes, and stadium insights across multiple seasons. The project applies joins, aggregations, and advanced queries to generate meaningful sports analytics.

# ⚽ UEFA SQL Data Analysis Project

## 📌 Overview

The Union of European Football Associations (UEFA) is the administrative and controlling body for European football. Founded on June 15, 1954, in Basel, Switzerland, UEFA is one of the six continental confederations of FIFA. It consists of 55 member associations.

UEFA organizes:
- UEFA Champions League
- UEFA Europa League
- UEFA European Championship (Euros)
- UEFA Nations League

---

## 📊 Dataset Overview

This project uses five CSV files:
- Goals.csv
- Matches.csv
- Players.csv
- Teams.csv
- Stadiums.csv

---

## 📚 Data Dictionary

### Goals.csv

| Column | Type | Description |
|--------|------|------------|
| GOAL_ID | String | Unique goal identifier |
| MATCH_ID | String | Match identifier |
| PID | String | Player ID |
| DURATION | Integer | Minute of goal |
| ASSIST | String | Assisting player |
| GOAL_DESC | String | Goal description |

---

### Matches.csv

| Column | Type | Description |
|--------|------|------------|
| MATCH_ID | String | Unique match ID |
| SEASON | String | Season |
| DATE | String | Match date |
| HOME_TEAM | String | Home team |
| AWAY_TEAM | String | Away team |
| STADIUM | String | Stadium |
| HOME_TEAM_SCORE | Integer | Home score |
| AWAY_TEAM_SCORE | Integer | Away score |
| PENALTY_SHOOT_OUT | Integer | 1 = Yes, 0 = No |
| ATTENDANCE | Integer | Attendance |

---

### Players.csv

| Column | Type | Description |
|--------|------|------------|
| PLAYER_ID | String | Unique ID |
| FIRST_NAME | String | First name |
| LAST_NAME | String | Last name |
| NATIONALITY | String | Nationality |
| DOB | Date | Date of birth |
| TEAM | String | Team |
| JERSEY_NUMBER | Float | Jersey number |
| POSITION | String | Position |
| HEIGHT | Float | Height |
| WEIGHT | Float | Weight |
| FOOT | String | Preferred foot |

---

### Teams.csv

| Column | Type | Description |
|--------|------|------------|
| TEAM_NAME | String | Team name |
| COUNTRY | String | Country |
| HOME_STADIUM | String | Home stadium |

---

### Stadiums.csv

| Column | Type | Description |
|--------|------|------------|
| NAME | String | Stadium |
| CITY | String | City |
| COUNTRY | String | Country |
| CAPACITY | Integer | Capacity |

---

## 🚀 Tasks

Load the datasets into PostgreSQL and solve:

### Goal Analysis
1. Top scorer per season  
2. Goals per player per season  
3. Goals in match mt403  
4. Top assist per season  
5. Players scoring in >10 matches  
6. Avg goals per match  
7. Most goals in one match  
8. Top scoring team overall  
9. Stadium with most goals  

### Match Analysis
10. Highest scoring match  
11. Draw matches  
12. Highest avg score team  
13. Penalty shootouts count  
14. Avg attendance  
15. Most used stadium  
16. Matches by country  
17. Common match result  

### Player Analysis
18. Goals + assists leaders  
19. Avg height & weight  
20. Most left-foot goals  
21. Avg age per team  
22. Players per team  
23. Most matches played  
24. Common position  
25. Players with no goals  

### Team Analysis
26. Largest stadium  
27. Teams per country  
28. Top scoring team  
29. Teams per city  
30. Most home wins  

### Stadium Analysis
31. Highest capacity  
32. Stadiums in Russia/London  
33. Most matches hosted  
34. Avg capacity  
35. Teams in >50k stadiums  
36. Highest attendance stadium  
37. Capacity distribution  

### Cross Analysis
38–50. Multi-table queries  

### Advanced Queries
51–55. Complex SQL analysis  

---

## 🛠️ Tools
- PostgreSQL
- SQL
