

## Import Libraries

library(stringr)
library(BBmisc)

## Read File after placing file in current Working Directory

chessinfo = read.csv("tournamentinfo.txt",FALSE,sep = "|")


## Data Cleansing for unique items to remove -------
dfdirty = unique(chessinfo)
dfdirty = dfdirty[-1,-11]
colnames(dfdirty) = c("Pair","Player_Name","Total","Round 1","Round 2","Round 3","Round 4","Round 5","Round 6","Round 7")
dfdirty = dfdirty[-1:-2,]

## Cleansing to extract scores, states, and ids

Playernamedirty = unlist(dfdirty$Player_Name)
state = unlist(dfdirty$Pair)
play_states = unlist(str_extract_all(state,"[[:alpha:]]{2}"))
id_scores = str_extract_all(Playernamedirty,"[[:digit:]]{2,}")
uscfid = str_extract_all(id_scores,"[[:digit:]]{8,}")
pre_scores_matrix =matrix(unlist(str_extract_all(id_scores,"[[:digit:]]{3,}")),ncol = 3,byrow= TRUE)

## conversion to numeric to remove NAs and creation of temporary matrix

dfdirty$Pair = as.numeric(as.character(dfdirty$Pair))
moderately_clean_df = dfdirty[complete.cases(dfdirty$Pair),]
moderately_clean_df$Pre_Scores = pre_scores_matrix[,2]
moderately_clean_df$Post_Scores = pre_scores_matrix[,3]
moderately_clean_df$Player_States = play_states

## extraction of player ids and game results

list_round1_id = str_extract_all(moderately_clean_df$`Round 1`,"[[:digit:]]{2,}")
list_round1_decision = unlist(str_extract_all(moderately_clean_df$`Round 1`,"[[:alpha:]]{1,}"))
list_round2_id = str_extract_all(moderately_clean_df$`Round 2`,"[[:digit:]]{2,}")
list_round2_decision = unlist(str_extract_all(moderately_clean_df$`Round 2`,"[[:alpha:]]{1,}"))
list_round3_id = str_extract_all(moderately_clean_df$`Round 3`,"[[:digit:]]{2,}")
list_round3_decision = unlist(str_extract_all(moderately_clean_df$`Round 3`,"[[:alpha:]]{1,}"))
list_round4_id = str_extract_all(moderately_clean_df$`Round 4`,"[[:digit:]]{2,}")
list_round4_decision = unlist(str_extract_all(moderately_clean_df$`Round 4`,"[[:alpha:]]{1,}"))
list_round5_id = str_extract_all(moderately_clean_df$`Round 5`,"[ [:digit:]]{2,}")
list_round5_id = trimws(list_round5_id)
list_round5_decision = unlist(str_extract_all(moderately_clean_df$`Round 5`,"[[:alpha:]]{1,}"))
list_round6_id = str_extract_all(moderately_clean_df$`Round 6`,"[[:digit:]]{2,}")
list_round6_decision = unlist(str_extract_all(moderately_clean_df$`Round 6`,"[[:alpha:]]{1,}"))
list_round7_id = str_extract_all(moderately_clean_df$`Round 7`,"[ [:digit:]]{2,}")
list_round7_id = trimws(list_round7_id,"l")
list_round7_decision = unlist(str_extract_all(moderately_clean_df$`Round 7`,"[[:alpha:]]{1,}"))

## modification with player ids and results to primary table

moderately_clean_df$Round1_Result = list_round1_decision
moderately_clean_df$Round2_Result = list_round2_decision
moderately_clean_df$Round3_Result = list_round3_decision
moderately_clean_df$Round4_Result = list_round4_decision
moderately_clean_df$Round5_Result = list_round5_decision
moderately_clean_df$Round6_Result = list_round6_decision
moderately_clean_df$Round7_Result = list_round7_decision
moderately_clean_df$Round1_Player_ID = list_round1_id
moderately_clean_df$Round2_Player_ID = list_round2_id
moderately_clean_df$Round3_Player_ID = list_round3_id
moderately_clean_df$Round4_Player_ID = list_round4_id
moderately_clean_df$Round5_Player_ID = list_round5_id
moderately_clean_df$Round6_Player_ID = list_round6_id
moderately_clean_df$Round7_Player_ID = list_round7_id

## Cleansing of newly added columsn
moderately_clean_df$Round1_Player_ID[moderately_clean_df$Round1_Player_ID == "character(0)"] =  0
moderately_clean_df$Round2_Player_ID[moderately_clean_df$Round2_Player_ID == "character(0)"] =  0
moderately_clean_df$Round3_Player_ID[moderately_clean_df$Round3_Player_ID == "character(0)"] =  0
moderately_clean_df$Round4_Player_ID[moderately_clean_df$Round4_Player_ID == "character(0)"] =  0
moderately_clean_df$Round5_Player_ID[moderately_clean_df$Round5_Player_ID == ""] =  0
moderately_clean_df$Round6_Player_ID[moderately_clean_df$Round6_Player_ID == "character(0)"] =  0
moderately_clean_df$Round7_Player_ID[moderately_clean_df$Round7_Player_ID == ""] =  0

## Looping to parse out average pre scores

playeridlist = list()

for(i in 1:length(moderately_clean_df$Pair)){
  playeridlist[i] = convertRowsToList(moderately_clean_df[i,21:27])
}

playeridlistnolists = as.numeric(unlist(playeridlist))

temptable = moderately_clean_df[,c("Pair","Pre_Scores")]
rownames(temptable) = temptable$Pair
temptable = temptable[,-1]

list_pre_average_Scores = list()

for(i in 1:length(playeridlistnolists)){
  if(as.numeric(playeridlistnolists[i]) == 0){
    list_pre_average_Scores[i] = 0
  } 
  else{
    list_pre_average_Scores[i] = temptable[playeridlistnolists[i]]}
}


listoflistsprescores = list()
for(i in 1:64){
  b = 7 * i
  a = ifelse(i == 1, 1, b-6)
  listoflistsprescores[i] = list(as.numeric(unlist(list_pre_average_Scores[a:b])))
  }

prescoresfinal = list()
for(i in 1:64){
  prescoresfinal[i] = sum(listoflistsprescores[[i]])/length(listoflistsprescores[[i]][unlist(listoflistsprescores[[i]])!=0])
}

moderately_clean_df$Average_Pre_Scores = prescoresfinal


## Subset for clean df and write to csv

cleandf = moderately_clean_df[,c("Player_Name","Player_States","Total","Pre_Scores","Average_Pre_Scores")]

cleandf = apply(cleandf,2,as.character)

print(cleandf)

write.csv(cleandf, file = "CleanChessData.csv",row.names = FALSE)

