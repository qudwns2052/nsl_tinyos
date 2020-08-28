# nsl_tinyos

1. TestRPL_start_stop
https://github.com/qudwns2052/nsl_tinyos/tree/master/TestRPL_start_stop
sfsend를 root에 전달 -> root는 Multicast로 udp msg 전달 -> 이를 받은 node들은 Timer를 start or stop

2. TestRPL_command
sfsend에 command를 추가 -> 00인 경우는 Timer를 stop / 01인 경우는 Timer를 start

3. TestRPL_multihop
onehop이 아닌 multihop으로 구현 -> TX_POWER를 3으로 낮춤 -> 자신의 DefaultRouter를 출력하여 이를 확인

4.
 

5.추후 계획

현재까지는, TestRPL의 코드만 수정 및 추가하였지만, 앞으로는 sfsend 및 sflisten을 수정하여 하나로 만들고, 제가 출력 및 입력값을 잘 확인할 수 있도록 하나로 합치면서 공부할 계획입니다. 또한, 2번의 command 부분을 encoding작업을 할 계획입니다. 마지막으로, 교수님께서 언급하신 signal strength 부분을 RSSI에서 가져와, 이를 활용하는 것을 공부할 계획입니다. (너무 낮은 strength는 안 받은 것처럼 작동하도록 하는 등)

 

