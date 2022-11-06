#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\n~~~~~ Number guessing game ~~~~~\n"

echo Enter your username:
if [[ -z $1 ]];
then
  read INPUT
else
  INPUT=$1
fi 
#
EXECUTE_GAME()
{
  
  # check username has atleast 22 characters
  # welcome message
  if [[  ${#INPUT} -le 22 ]];
  then
  echo -e "\nEnter username which is more than or equal to 22 characters length."
  fi

  GET_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$INPUT'")
  NAME=$INPUT
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$INPUT'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$INPUT'")

  if [[ -z $GET_RESULT ]];
  then
    INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$INPUT', 0)")
    echo -e "\nWelcome, $INPUT! It looks like this is your first time here."
  else
    
    echo -e "\nWelcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi


GENERATE_RANDOM
RUN_GAME
}
#guess random
GENERATE_RANDOM()
{
  GUESS_COUNT=0
  SECRET_NUMBER=$(( RANDOM % 1000))
  (( GAMES_PLAYED++ ))
  
  INCREASE_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username='$INPUT'")

  echo Guess the secret number between 1 and 1000:
}
RUN_GAME()
{
  read USER_GUESS
  
  
  if [[ $USER_GUESS =~ ^[0-9]+$ ]];
  then 
  (( GUESS_COUNT++ ))
    if [[ $USER_GUESS -lt $SECRET_NUMBER ]];
    then
      echo "It's higher than that, guess again:"
      RUN_GAME
    elif [[ $USER_GUESS -gt $SECRET_NUMBER ]];
    then
      echo "It's lower than that, guess again:"
      RUN_GAME
    else

      GET_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$INPUT'")

      if [[ $GUESS_COUNT -lt $GET_BEST_GAME || -z $GET_BEST_GAME ]];
      then
        INSERT_BEST_GAMES=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE username = '$INPUT'")
      fi

      echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  else
    echo "That is not an integer, guess again:"
    RUN_GAME
  fi
}
EXECUTE_GAME

