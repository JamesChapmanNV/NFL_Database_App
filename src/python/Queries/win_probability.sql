
-- *** win_probability ***
-- Query produces table with 3rd quarter scores of all games
-- played by a given team (from input), 
-- AND whether that team won the game (Boolean).
-- The result is used, in the app, to find the probability of 
-- a given team (from input) to win the game based on 
-- the score at the end of the 3rd quarter (from input).
-- INPUT: (s) = (team_name) 
-- OUTPUT: all games played by input team with 3 columns
-- 		-third_quarter_team_scores- score of input team
-- 		-opponent_scores- same game
-- 		-winner_bool- if input team wins, NULL if tie
-- QUERY TYPE: Question 

/* Query explanation
********************
This query requires 2 VIEWs named 'all_final_game_scores' & 'all_third_quarter_scores'
VIEW 'all_final_game_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name
	-home_team_score
	-away_team_name
	-away_team_score
	-home_winner_bool (true if home team wins, NULL if tie )

VIEW 'all_third_quarter_scores' produces 6 attributes for each game:
	-game_id 
	-home_team_name 
	-home_team_score (at end of 3rd quarter)
	-away_team_name
	-away_team_score (at end of 3rd quarter)
	-away_team_winng_bool (true if AWAY team is currently winning, NULL if tie )
********************

This query is split into 2 subqueries, to find all games that input team
played as home team, and games played as away team.

Each subquery joins the 2 views (all_final_game_scores & all_third_quarter_scores)
and matches the input team name to home_team_name/away_team_name, respectively.

Note the NOT operator on the away team subquery (bottom).  This is because
all_final_game_scores.home_winner_bool is true if the home team wins.

****************************************
Sample Query result (s) = (Texans)

 third_quarter_team_scores | opponent_scores | winner_bool
---------------------------+-----------------+-------------
                        20 |               6 | f
                         8 |              14 | f
                        14 |              24 | f
                        14 |              10 | t
                        17 |               3 | t
                        20 |               7 | t
                        21 |              16 | t
                        33 |               3 | t
                        20 |              24 | f
. . .
(186 rows)

****************************************
IN APP PROCESSING OF QUERY 
(logistic regression, unique to each team)
team_score- input of current 3rd quarter team score
opponent_score- input of current 3rd quarter opponents score

df = pd.DataFrame(self.last_result, columns=['third_quarter_team_scores', 'opponent_scores', 'winner_bool'])
df.loc[(df['winner_bool']=='f'),'winner_bool']= -1 # given team wins
df.loc[(df['winner_bool']=='t'),'winner_bool']= 1 # opponent wins
df.loc[(df['winner_bool'].isnull()),'winner_bool']= 0 # tie
df.fillna(0, inplace=True)
df['winner_bool'] = df['winner_bool'].astype('int64')
X = df[['third_quarter_team_scores', 'opponent_scores']] # features
y = df['winner_bool']  # Targets where -1 = away win, 0 = tie, 1 = home win
model = LogisticRegression(multi_class='multinomial', solver='lbfgs').fit(X.values, y.values)
probabilities = model.predict_proba([[team_score, opponent_score]])[0]
given_team_index = np.where(model.classes_==1)[0][0]
# display results
print(f'Given a score of {team_score} to {opponent_score},')
print(f'The probability of the {team_name} winning is {round(probabilities[given_team_index]*100, 1)}%')
****************************************

Sample app result - Texans 25 25



*/

SELECT y.home_team_score AS third_quarter_team_scores, 
		y.away_team_score AS opponent_scores, 
		x.home_winner_bool AS winner_bool
FROM all_final_game_scores x
JOIN all_third_quarter_scores y 
	ON x.game_id = y.game_id 
WHERE y.home_team_name = %s
UNION ALL
SELECT y.away_team_score AS third_quarter_team_scores, 
		y.home_team_score AS opponent_scores, 
		NOT x.home_winner_bool AS winner_bool
FROM all_final_game_scores x
JOIN all_third_quarter_scores y 
	ON x.game_id = y.game_id  
WHERE y.away_team_name = %s;