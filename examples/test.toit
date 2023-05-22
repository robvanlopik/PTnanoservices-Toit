import ..src.api show *
import encoding.json

main:
  tester := MQTTServiceClient "service2"
  tester.open
  5.repeat:
    r := random 10
    print r
    tester.publish "random" (json.encode r)
  tester.subscribe

  task :: checkDataOnMQTT tester


checkDataOnMQTT client/MQTTServiceClient:
  while true:
    answer := client.getMessage
    if answer == null: sleep --ms=5000
    else:
      print "topic: $answer[0] data: $answer[1]"


