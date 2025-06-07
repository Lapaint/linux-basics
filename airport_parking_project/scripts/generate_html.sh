#!/bin/bash

INPUT="/data/data.xml"
OUTPUT="/data/parking.html"

cat <<EOF > $OUTPUT
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>공항 주차장 실시간 정보</title>
  <style>
    body { font-family: 'Segoe UI', sans-serif; margin: 20px; }
    h1 { color: #333; }
    input[type="text"] {
      padding: 8px;
      width: 300px;
      margin-bottom: 20px;
      border: 1px solid #ccc;
      font-size: 14px;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      overflow-x: auto;
      display: block;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 10px;
      text-align: center;
    }
    th {
      background-color: #f9f9f9;
    }
    td:nth-child(5) {
      font-weight: bold;
    }
  </style>
  <script>
    function filterTable() {
      var input = document.getElementById("searchInput");
      var filter = input.value.toLowerCase();
      var rows = document.getElementById("dataTable").getElementsByTagName("tr");
      for (var i = 1; i < rows.length; i++) {
        var airport = rows[i].getElementsByTagName("td")[0];
        if (airport) {
          var txtValue = airport.textContent || airport.innerText;
          rows[i].style.display = txtValue.toLowerCase().indexOf(filter) > -1 ? "" : "none";
        }
      }
    }
  </script>
</head>
<body>
  <h1>전국 공항 실시간 주차장 정보</h1>
  <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="공항명을 입력하세요...">

  <table id="dataTable">
    <tr><th>공항명</th><th>주차장명</th><th>총면수</th><th>현재주차</th><th>혼잡도</th></tr>
EOF

grep -oP '<aprKor>.*?</aprKor>|<parkingAirportCodeName>.*?</parkingAirportCodeName>|<parkingFullSpace>.*?</parkingFullSpace>|<parkingIstay>.*?</parkingIstay>' "$INPUT" | \
sed -e 's/<[^>]*>//g' | \
paste - - - - | while IFS="$(printf '\t')" read AIRPORT LOT FULL STAY; do
  if [ "$FULL" -eq 0 ] 2>/dev/null; then
    LEVEL="정보 없음"; COLOR="gray"
  else
    PERCENT=$((100 * STAY / FULL))
    if [ $PERCENT -lt 50 ]; then LEVEL="여유"; COLOR="green"
    elif [ $PERCENT -lt 80 ]; then LEVEL="보통"; COLOR="orange"
    else LEVEL="혼잡"; COLOR="red"
    fi
  fi
  echo "<tr><td>$AIRPORT</td><td>$LOT</td><td>$FULL</td><td>$STAY</td><td style=\"color:$COLOR\">$LEVEL</td></tr>" >> "$OUTPUT"
done

cat <<EOF >> $OUTPUT
  </table>
  <p>※ 본 정보는 공공데이터포털 API를 기반으로 5분마다 자동 갱신됩니다.</p>
  <p style="font-size:12px; color:gray;">마지막 갱신 시각: <script>document.write(new Date().toLocaleString())</script></p>
</body>
</html>
EOF
