#!/bin/bash
SERVICE_KEY="FPZxGrVmevoBMeGnaWGBxMAd7UntrbLUPGTawn2XqUYYbcReRmYrFbfc6LefK3k5Kp6YfNGYgE0QILQfDKkWlw%3D%3D"
API_URL="http://openapi.airport.co.kr/service/rest/AirportParking/airportparkingRT?serviceKey=$SERVICE_KEY"
curl -s "$API_URL" -o /data/data.xml
