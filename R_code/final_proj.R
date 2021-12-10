library(tidyverse)
library(ggplot2)

choke_list_frame <- read.csv(file="/Users/elijahflomen/Desktop/choke_list_full_R.csv")
pbp_frame <- read.csv(file="/Users/elijahflomen/Desktop/pbp_data_full_R.csv")

# Initial box and whisker plot to just show the distribution of chokes per season:
ggplot(choke_list_frame, aes(season)) + geom_boxplot() + coord_flip()

# Finds all instances where a home team choked
home_team_chokes <- choke_list_frame %>% filter(home_choke == 1) %>% count(home_team)
# Finds all instances where an away team choked
away_team_chokes <- choke_list_frame %>% filter(home_choke == 0) %>% count(away_team)

# Finds all instances of a home team comeback
home_team_comebacks <- choke_list_frame %>% filter(home_choke == 0) %>% count(home_team)
# Finds all instances of an away team comeback
away_team_comebacks <- choke_list_frame %>% filter(home_choke == 1) %>% count(away_team)

# Aggregates total overall chokes for a all teams
team_total_chokes <- transmute(home_team_chokes, home_team, total_chokes=home_team_chokes$n + away_team_chokes$n)
team_total_chokes <- team_total_chokes %>% rename(team=home_team) %>% arrange(team_total_chokes$total_chokes)

# Aggregates total overall comebacks for all teams
team_total_comebacks <- transmute(home_team_comebacks, home_team, total_comebacks=home_team_comebacks$n + away_team_comebacks$n)
team_total_comebacks <- team_total_comebacks %>% rename(team=home_team) %>% arrange(team)

# GRAPH: Cleveland dot plot for total chokes per team
total_chokes_plot <- ggplot(team_total_chokes, aes(reorder(team, total_chokes), total_chokes)) + geom_point(stat='identity') + coord_flip()
total_chokes_plot
# GRAPH: Cleveland dot plot for total comebacks per team
total_comebacks_plot <- ggplot(team_total_comebacks, aes(reorder(team, total_comebacks), total_comebacks)) + geom_point(stat='identity') + coord_flip()
total_comebacks_plot

# By inspection of the data, it is interesting to note that a team can be both a high choke and high comeback team
# It is possible, they just have extremely 

# GRAPH: High Choke and High Comeback teams:
team_totals <- team_total_chokes %>% left_join(team_total_comebacks, by='team')
ggplot(team_totals) + geom_point(aes(total_chokes, total_comebacks)) + 
  geom_text(aes(total_chokes, total_comebacks, label=team), hjust=0, vjust=0)

# Gets all of the play-by-play data for the games where a home team choked
home_choke_pbp <- pbp_frame %>% group_by(game_id) %>% filter(max(visitor_pts) > max(home_pts))
# Looks at each game event description and then assigns a categorical variable to each time a home team makes a mistake
# Looks for turnovers, fouls and missed shots
home_choke_pbp <- home_choke_pbp %>% mutate(home_mistake = ifelse(grepl("Turnover", home_desc), 'turnover', 
                                                           ifelse(grepl("FOUL", home_desc), 'foul',
                                                           ifelse(grepl("MISS", home_desc), 'miss', '')))) 

# Repeat the same process for the away team chokes play-by-play data
away_choke_pbp <- pbp_frame %>% group_by(game_id) %>% filter(max(home_pts) > max(visitor_pts))
away_choke_pbp <- away_choke_pbp %>% mutate(away_mistake = ifelse(grepl("Turnover", visitor_desc), 'turnover', 
                                                           ifelse(grepl("FOUL", visitor_desc), 'foul',
                                                           ifelse(grepl("MISS", visitor_desc), 'miss', '')))) 


# Here, we want to look to classifiy each choke by a single cause, to determine the leading causes for a team to lose
home_choke_reasons <- home_choke_pbp %>% group_by(game_id) %>% count(home_mistake) %>% na_if("") %>% na.omit
away_choke_reasons <- away_choke_pbp %>% group_by(game_id) %>% count(away_mistake) %>% na_if("") %>% na.omit

# We do this by looking at the count of each mistake for a team that choked per game. 
# We then want to standardize the frequency of these mistakes by dividing them by the league averages
# This method allows us to identify the mistake that was most frequent in a choke
home_choke_reasons_frac <- home_choke_reasons %>% mutate(frac = ifelse(home_mistake == 'turnover', n/14.3,
                                                                ifelse(home_mistake == 'miss', n/48,
                                                                ifelse(home_mistake == 'foul', n/19, 0))))

away_choke_reasons_frac <- away_choke_reaosns %>% mutate(frac = ifelse(away_mistake == 'turnover', n/14.3,
                                                               ifelse(away_mistake == 'miss', n/48,
                                                               ifelse(away_mistake == 'foul', n/19, 0))))

home_choke_reason_max <- home_choke_reasons_frac %>% group_by(game_id) %>% filter(frac==max(frac))
away_choke_reason_max <- away_choke_reasons_frac %>% group_by(game_id) %>% filter(frac==max(frac))

# GRAPH 3: Leading Causes for a home-team choke
ggplot(home_choke_reason_max) + geom_bar(aes(home_mistake))

# GRAPH 4: Leading Causes for an away-team choke
ggplot(away_choke_reason_max) + geom_bar(aes(away_mistake))

# NOW, LETS ZOOM IN ON A SPECIFIC PLAYOFF SERIES: MIA v. BOSTON 





