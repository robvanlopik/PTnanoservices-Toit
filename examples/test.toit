import ..src.api show *
import encoding.json

main:
  tester := MQTTServiceClient "service2"
  tester.open
  5.repeat:
    r := random 10
    print r
    tester.publish "random" (json.encode r)

