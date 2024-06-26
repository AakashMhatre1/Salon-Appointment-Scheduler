#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c "
echo -e "\n~~~~~ MY SALAON ~~~~~\n"

echo -e "\nWelcome to My Salon, How can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_AVAILABLE=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_AVAILABLE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    ADD_CUST_NAME=$($PSQL "INSERT INTO customers(phone, name)VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi

    GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    SERVICE_NAME=$(echo $GET_SERVICE_NAME | sed 's/ //g')
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME
    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."  
  fi
}
MAIN_MENU
