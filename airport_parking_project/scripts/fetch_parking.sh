#!/bin/bash
SERVICE_KEY="여기에 서비스키를 입력하세요"
API_URL="http://openapi.airport.co.kr/service/rest/AirportParking/airportparkingRT?serviceKey=$SERVICE_KEY"
curl -s "$API_URL" -o /data/data.xml
