#!/bin/bash

INPUT="/data/data.xml"
OUTPUT="/data/parking.html"
TIME=$(date "+%Y-%m-%d %H:%M:%S")

cat <<EOHTML > "$OUTPUT"
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
      text-align: center;
    }
    h1 {
      color: #333;
    }
    #searchBar {
      margin: 20px 0;
    }
    input[type="text"] {
      padding: 8px;
      font-size: 16px;
      width: 280px;
      border: 1px solid #ccc;
      border-radius: 5px;
    }
    button {
      padding: 8px 16px;
      font-size: 16px;
      background-color: #4a6cf7;
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;
    }
    button:hover {
      background-color: #2f4ec4;
    }
    table {
      width: 90%;
      margin: 0 auto;
      border-collapse: collapse;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 12px;
    }
    th {
      background-color: #f2f2f2;
      font-weight: bold;
      cursor: pointer;
    }
    tr:hover {
      background-color: #f5f5f5;
    }
    a {
      color: inherit;
      text-decoration: none;
    }
    .level {
      font-weight: bold;
    }
    .green { color: green; }
    .orange { color: orange; }
    .red { color: red; }
    .gray { color: gray; }
    .timestamp {
      color: #777;
      font-size: 14px;
      margin-bottom: 10px;
    }
  </style>
  <script>
    function filterRows() {
      const input = document.getElementById("searchInput").value.trim();
      const rows = document.querySelectorAll("tbody tr");
      rows.forEach(row => {
        row.style.display = row.innerText.includes(input) ? "" : "none";
      });
      sessionStorage.setItem("search", input);
    }

    let sortState = {
      '공항명': 'none',
      '주차장명': 'none',
      '남은자리': 'none',
      '혼잡도': 'none'
    };

    function sortTable(colIndex, type) {
      const table = document.querySelector("table tbody");
      const rows = Array.from(table.querySelectorAll("tr"));
      const current = sortState[type];
      const next = current === "asc" ? "desc" : "asc";
      sortState[type] = next;

      const levelOrder = {"여유": 1, "보통": 2, "혼잡": 3};

      rows.sort((a, b) => {
        let valA = a.children[colIndex].innerText.replace("대", "").trim();
        let valB = b.children[colIndex].innerText.replace("대", "").trim();

        if (type === "혼잡도") {
          valA = levelOrder[valA] || 99;
          valB = levelOrder[valB] || 99;
        } else if (type === "남은자리") {
          valA = parseInt(valA);
          valB = parseInt(valB);
        }

        if (valA < valB) return next === "asc" ? -1 : 1;
        if (valA > valB) return next === "asc" ? 1 : -1;
        return 0;
      });

      rows.forEach(row => table.appendChild(row));
      sessionStorage.setItem("sortColumn", colIndex);
      sessionStorage.setItem("sortType", type);
      sessionStorage.setItem("sortOrder", next);
    }

    document.addEventListener("DOMContentLoaded", () => {
      const searchSaved = sessionStorage.getItem("search");
      if (searchSaved) {
        const inputBox = document.getElementById("searchInput");
        inputBox.value = searchSaved;
        filterRows();
      }

      const savedCol = sessionStorage.getItem("sortColumn");
      const savedType = sessionStorage.getItem("sortType");
      const savedOrder = sessionStorage.getItem("sortOrder");

      if (savedCol && savedType && savedOrder) {
        sortState[savedType] = savedOrder === "asc" ? "desc" : "asc";
        sortTable(parseInt(savedCol), savedType);
      }

      document.getElementById("searchInput").addEventListener("input", filterRows);
    });
  </script>
</head>
<body>
  <h1>전국 공항 실시간 주차장 정보</h1>
  <div class="timestamp">마지막 갱신: ${TIME}</div>
  <div id="searchBar">
    <input type="text" id="searchInput" placeholder="공항명 또는 주차장을 입력하세요">
  </div>
  <table>
    <thead>
      <tr>
        <th onclick="sortTable(0, '공항명')">공항명</th>
        <th onclick="sortTable(1, '주차장명')">주차장명</th>
        <th onclick="sortTable(2, '남은자리')">남은 자리</th>
        <th onclick="sortTable(3, '혼잡도')">혼잡도</th>
      </tr>
    </thead>
    <tbody>
EOHTML

# 데이터 파싱
grep -oP '<aprKor>.*?</aprKor>|<parkingAirportCodeName>.*?</parkingAirportCodeName>|<parkingFullSpace>.*?</parkingFullSpace>|<parkingIstay>.*?</parkingIstay>' "$INPUT" \
| sed -e 's/<[^>]*>//g' \
| paste - - - - \
| while IFS="$(printf '\t')" read AIRPORT LOT FULL STAY; do
  if [ "$FULL" -eq 0 ] 2>/dev/null; then
    LEVEL="정보 없음"; COLOR="gray"; LEFT="정보 없음"
  else
    LEFT=$((FULL - STAY))
    PERCENT=$((100 * STAY / FULL))
    if [ "$PERCENT" -lt 50 ]; then LEVEL="여유"; COLOR="green"
    elif [ "$PERCENT" -lt 80 ]; then LEVEL="보통"; COLOR="orange"
    else LEVEL="혼잡"; COLOR="red"
    fi
  fi
  LINK="https://www.google.com/maps/search/$(echo "$AIRPORT $LOT" | sed 's/ /+/g')"
  echo "<tr><td>$AIRPORT</td><td><a href=\"$LINK\" target=\"_blank\">$LOT</a></td><td>${LEFT}대</td><td class=\"level $COLOR\">$LEVEL</td></tr>" >> "$OUTPUT"
done

cat <<EOHTML >> "$OUTPUT"
    </tbody>
  </table>
</body>
</html>
EOF

chmod +x /scripts/generate_html.sh
EOF
