# NFL_database


Work in progress …

Current tables are as follows:

**Teams**

| <ins>team_id</ins> | name | location | abbreviation | primaryColor | secondaryColor |
| ------------------ | ---- | -------- | ------------ | ------------ | -------------- |

**Positions**

| <ins>position_id</ins> | abbreviation | name |
| ---------------------- | ------------ | ---- |

**Athletes**

| <ins>athlete_id </ins> | firstName | lastName | dateOfBirth | jersey | height | weight | birth_place | drafted_bool |
| ---------------------- | --------- | -------- | ----------- | ------ | ------ | ------ | ----------- | ------------ |

**Rosters**

| <ins>game_id</ins> | <ins>athlete_id</ins> | <ins>team_id</ins> | position_id | active | didNotPlay |
| ------------------ | --------------------- | ------------------ | ----------- | ------ | ---------- |

**Venues**

| <ins>venue_id</ins> | fullName | capacity | city | state | zipCode | grass | indoor | venue_id |
| ------------------- | -------- | -------- | ---- | ----- | ------- | ----- | ------ | -------- |

**Games**

| <ins>game_id</ins> | name | shortName | attendance | date | seasonType | year | week | home_win | home_team_id | away_team_id |
| ------------------ | ---- | --------- | ---------- | ---- | ---------- | ---- | ---- | -------- | ------------ | ------------ |


**Plays**

| <ins>play_id</ins> | game_id | text | quarter | playType | yards | scoreValue | secondsRemaining |
| ------------------ | ------- | ---- | ------- | -------- | ----- | ---------- | ---------------- |

**Player_Plays**

| <ins>game_id</ins> | <ins>play_id</ins> | <ins>player_id</ins> | type |
| ------------------ | ------------------ | -------------------- | ---- |

**Linescores**

| <ins>game_id</ins> | <ins>team_id</ins> | </ins>quarter</ins> | score |
| ------------------ | ------------------ | ------------------- | ----- |



<a target="_blank" href="https://colab.research.google.com/github/JamesChapmanNV/NFL_database/blob/main/ESPN_WebScraping.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>
