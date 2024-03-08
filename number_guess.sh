#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~ Number Guessing Game ~~~\n"
echo Enter your username:
read USERNAME
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here.\n"
  INSERT_RESULT=$($PSQL "insert into users(username) values ('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
else
  USER_NAME=$($PSQL "select username from users where user_id=$USER_ID")
  GAMES_PLAYED=$($PSQL "select count(user_id) from games where user_id=$USER_ID")
  BEST_GAME=$($PSQL "select min(total_guesses) from games where user_id=$USER_ID")
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((( RANDOM % 1000 )))
TOTAL_GUESSES=0
IS_GUESSED=0

echo -e "\nGuess the secret number between 1 and 1000:"
while [[ IS_GUESSED -eq 0 ]]
do
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      TOTAL_GUESSES=$(($TOTAL_GUESSES + 1))
      echo -e "\nYou guessed it in $TOTAL_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      INSERT_GAME_RESULT=$($PSQL "insert into games(user_id, total_guesses) values($USER_ID, $TOTAL_GUESSES)")
      IS_GUESSED=1
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      TOTAL_GUESSES=$(($TOTAL_GUESSES + 1))
    else
      echo -e "\nIt's higher than that, guess again:"
      TOTAL_GUESSES=$(($TOTAL_GUESSES + 1))
    fi
  else
    echo -e "\nThat is not an integer, guess again:"
    TOTAL_GUESSES=$(($TOTAL_GUESSES + 1))
  fi
done
