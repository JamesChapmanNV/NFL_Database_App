# NFL_database


Work in progress …

Current tables are as follows:

**Teams**

| <ins>team_id</ins> | name | location | abbreviation | primaryColor | secondaryColor |
| ------------------ | ---- | -------- | ------------ | ------------ | -------------- |

**Positions**

| <ins>position_id</ins> | abbreviation | name |
| ---------------------- | ------------ | ---- |

**Players**

| <ins>player_id </ins> | firstName | lastName | dateOfBirth | jersey | height | weight |
| --------------------- | --------- | -------- | ----------- | ------ | ------ | ------ |

**Venues**

| <ins>venue_id</ins> | fullName | capacity | city | state | zipCode | grass | indoor |
| ------------------- | -------- | -------- | ---- | ----- | ------- | ----- | ------ |

**Games**

| <ins>game_id</ins> | name | shortName | attendance | date | seasonType | year | week | home_win |
| ------------------ | ---- | --------- | ---------- | ---- | ---------- | ---- | ---- | -------- |

**Plays**

| <ins>play_id</ins> | text | quarter | playType | yards | scoreValue | secondsRemaining |
| ------------------ | ---- | ------- | -------- | ----- | ---------- | ---------------- |

**Linescores**

| <ins>game_id</ins> | <ins>team_id</ins> | </ins>quarter</ins> | score |
| ------------------ | ------------------ | ------------------- | ----- |



<a target="_blank" href="https://colab.research.google.com/github/JamesChapmanNV/NFL_database/blob/main/ESPN_WebScraping.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>
