#!/bin/bash
PSQL="psql  -X  --username=freecodecamp --dbname=salon  --tuples-only -c"

echo -e "\n~~~~~ JOY BEAUTY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
   then
   echo -e "\n$1"
  fi
 
 AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    # if service not available
    if [[ -z $AVAILABLE_SERVICES ]]
     then
     # print
     echo "Sorry, we do not have that service right now. What would you like today?"
   else 
     # display available services
     echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME 
       do 
      echo "$SERVICE_ID) $NAME"
      done 
   
      read SERVICE_ID_SELECTED
    
       # if input is not a number 
       if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
       then 
       # print
       MAIN_MENU "Sorry,that is not a valid service option."
       else
       # get service available
        AVAILABLE_SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

          # if not available
         if [[ -z $AVAILABLE_SERVICES ]]
          then
         # send to main menu
         MAIN_MENU "I could not find that service. What would you like today?"
        else
        # get customer info
         echo -e "\nWhat's your phone number?"
         read CUSTOMER_PHONE

          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

         # if customer name doesn't exist
          if [[ -z $CUSTOMER_NAME ]]
          then
         # print
         echo "I don't have a record for that phone number, what's your name?"
      
        read CUSTOMER_NAME
    
          # get new customer name
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

        fi
         # get service time
         echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $CUSTOMER_NAME?"
         read SERVICE_TIME
         CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
         # if service time is available
        if [[ $SERVICE_TIME ]]
         then
         # insert service appointment
         INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
     
           if [[  $INSERT_APPOINTMENT_RESULT ]]
           then
            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
            
         fi
        fi
      fi
    fi
  fi
}

MAIN_MENU
