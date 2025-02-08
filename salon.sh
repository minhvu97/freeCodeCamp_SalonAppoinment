#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -q -c"
echo -e "\nWelcome to My Salon, how can I help you?\n"

SERVICE_MENU() {
  # check if there is param
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # showing menu
  SERVICES_LIST=$($PSQL "select * from services")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  #read input
  read SERVICE_ID_SELECTED
  
  #check service exist
  # get service
  SELECTED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if service doesn't exist
  if [[ -z $SELECTED_SERVICE ]]
  then
    # send to main menu
    echo -e "\nThat is not a valid service."
    SERVICE_MENU
  else
    #get service from input
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

    #print out the service
    echo "You have picked $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')"
    echo -e "\nEnter you phone number"
    read CUSTOMER_PHONE
    if [[ -z $CUSTOMER_PHONE ]]
    then
      SERVICE_MENU "Invalid phone number"
    else
      #get the customer by phone number
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      #Check existing Customer
      if [[ -z $CUSTOMER_ID ]]
      then
        #create customer
        echo -e "\nPlease insert your name"
        read CUSTOMER_NAME
        INSERT_CUSTOMER=$($PSQL "insert into customers(name, phone) values ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      fi
      #get customer name
      CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")

      #set up the appointment
      echo -e "\nPlease choose your time:"
      read SERVICE_TIME
      #check valid 
      if [[ -z $SERVICE_TIME ]]
      then
        SERVICE_MENU "Invalid Time"
      else
        #insert into appoinments table
        INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
        #ending
        echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
      fi
    fi
  fi
}

SERVICE_MENU