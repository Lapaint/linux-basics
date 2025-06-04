#!/bin/bash

INPUT="/data/data.xml"
OUTPUT="/data/parking.html"
LAST_UPDATE=$(date +"%Y-%m-%d %H:%M:%S")

cat <<HTML > $OUTPUT
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>공항 주차장 실시간 정보</title>
  <meta http-equiv="refresh" content="5">
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background-color: #f9f9f9;
      margin: 40px;
    }
    h1 {
      color: #333;
      text-align: center;
    }
    #update-time {
      text-align: center;
      font-size: 14px;
      color: #888;
      margin-bottom: 10px;
    }
    #search {
      text-align: center;
      margin-bottom: 20px;
    }
    input[type="text"] {
      padding: 8px;
      font-size: 16px;
      width: 250px;
      border: 1px solid #ccc;
      border-radius: 5px;
    }
    button {
      padding: 8px 16px;
      font-size: 16px;
      background-color: #007BFF;
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;
    }
    button:hover {
      background-color: #0056b3;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 10px;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 12px;
      text-align: center;
    }
    th {
      background-color: #f1f1f1;
      cursor: pointer;
    }
    tr:hover {
      background-color: #f5f5f5;
    }
    a {
      text-decoration: none;
      color: inherit;
    }
  </style>
  <script>
    let currentSort = { col: -1, asc: true };

    function sortTable(n) {
      const table = document.querySelector("table");
      const rows = Array.from(table.rows).slice(1);
      const isAsc = currentSort.col === n ? !currentSort.asc : true;

      rows.sort((a, b) => {
        const valA = a.cells[n].innerText;
        const valB = b.cells[n].innerText;
        const numA = parseInt(valA);
        const numB = parseInt(valB);
        const cmp = isNaN(numA) || isNaN(numB) ? valA.localeCompare(valB) : numA - numB;
        return isAsc ? cmp : -cmp;
      });

      rows.forEach(row => table.appendChild(row));
      currentSort = { col: n, asc: isAsc };
    }

    function searchAirport() {
      const input = document.getElementById("airportInput").value.trim();
      const rows = document.querySelectorAll("tbody tr");
      rows.forEach(row => {
        row.style.display = row.innerText.includes(input) ? "" : "none";
      });
    }

    window.onload = () => {
      const inputBox = document.getElementById("airportInput");
      inputBox.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
          event.preventDefault();
          searchAirport();
        }
      });
    };
  </script>
</head>
<body>
  <h1>전국 공항 실시간 주차장 정보</h1>
  <div id="update-time">마지막 갱신: $LAST_UPDATE</div>
  <div id="search">
    <input type="text" id="airportInput" placeholder="공항명 또는 주차장을 입력하세요">
    <button onclick="searchAirport()">검색</button>
  </div>
  <table>
    <thead>
      <tr>
        <th onclick="sortTable(0)">공항명</th>
        <th onclick="sortTable(1)">주차장명</th>
        <th onclick="sortTable(2)">남은 자리</th>
        <th onclick="sortTable(3)">혼잡도</th>
      </tr>
    </thead>
    <tbody>
HTML

grep -oP '<aprKor>.*?</aprKor>|<parkingAirportCodeName>.*?</parkingAirportCodeName>|<parkingFullSpace>.*?</parkingFullSpace>|<parkingIstay>.*?</parkingIstay>' "$INPUT" | \
sed -e 's/<[^>]*>//g' | \
paste - - - - | while IFS="$(printf '\t')" read AIRPORT LOT FULL STAY; do
  if [ "$FULL" -eq 0 ] 2>/dev/null; then
    LEFT="정보 없음"
    LEVEL="정보 없음"
    COLOR="gray"
  else
    LEFT=$((FULL - STAY))
    PERCENT=$((100 * STAY / FULL))
    if [ $PERCENT -lt 50 ]; then LEVEL="여유"; COLOR="green"
    elif [ $PERCENT -lt 80 ]; then LEVEL="보통"; COLOR="orange"
    else LEVEL="혼잡"; COLOR="red"
    fi
  fi
  LOT_ESC=$(echo "$LOT" | sed 's/ /+/g')
  echo "<tr><td>$AIRPORT</td><td><a href=\"https://www.google.com/maps/search/$LOT_ESC\" target=\"_blank\">$LOT</a></td><td>${LEFT}대</td><td style=\"color:$COLOR\">$LEVEL</td></tr>" >> "$OUTPUT"
done

cat <<HTML >> $OUTPUT
    </tbody>
  </table>
</body>
</html>
HTML

