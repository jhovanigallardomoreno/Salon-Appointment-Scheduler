#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "What service would you like to request?"
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  NUM_SERVICES=$($PSQL "SELECT COUNT(name) FROM services")
  echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $(echo $SERVICE_NAME | sed -r 's/\|| //g')"
  done

  read SERVICE_ID_SELECTED
  
  case $SERVICE_ID_SELECTED in
    [1-$(echo $NUM_SERVICES | sed -r 's/ //g')]) REGISTER "$SERVICE_ID_SELECTED" ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac

}

REGISTER() {
  echo -e "\nPlease enter your phone number: "
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nWhen would you want your appointment?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED',  '$SERVICE_TIME')")

  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}

MAIN_MENU
