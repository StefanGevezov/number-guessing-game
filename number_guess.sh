#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  if [[ -z $USER_ID ]]
  then
    # The variable is empty, so this is a NEW player.
    # 1. Use $PSQL to INSERT their $USERNAME into the users table.
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    # 2. Print the exact new player welcome message required by the project.
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    # The variable has an ID, so this is a RETURNING player.
    # 1. Query the database to get their games played (COUNT) and best game (MIN guesses).
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
    # 2. Print the exact returning player welcome message using those stats.
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

while [[ $GUESS != $SECRET_NUMBER ]]
do
  # The if statement is INSIDE the do/done block
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    # We will put the higher/lower checks here next
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
  
  # We will also need to ask for their next guess inside the loop
  read GUESS
  ((NUMBER_OF_GUESSES++))
done

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
