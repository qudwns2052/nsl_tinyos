# nsl_tinyos

1. TestRPL_start_stop

sfsend를 root에 전달 -> root는 Multicast로 udp msg 전달 -> 이를 받은 node들은 Timer를 start or stop


2. TestRPL_command

sfsend에 command를 추가 -> 00인 경우는 Timer를 stop / 01인 경우는 Timer를 start


3. TestRPL_multihop

onehop이 아닌 multihop으로 구현 -> TX_POWER를 3으로 낮춤 -> 자신의 DefaultRouter를 출력하여 이를 확인


4. TestRPL_RSSI

metadata에 있는 RSSI를 추출 -> 수신 신호 세기 check 과정 추가


5. TestRPL_sfsend_node_id

sfsend의 형식을 id command로 변환 -> node가 0이면 all / 0이 아니면, 자신의 TOS_NODE_ID와 비교하여 같으면 command 실행


6. TestRPL_sfsend_forwarding

multihop의 경우, Depth가 2일 때 root로부터 한번에 받지 못함 -> 이 경우, Depth 1이 forwarding을 해주는 기능 추가
