// Author: Rob van Lopik
// License: MIT
// inspired by githun:/kasperl//

import system.services
import encoding.json

interface MQTTService:
  static SELECTOR ::= services.ServiceSelector
      --uuid="abacadabra"
      --major=1
      --minor=0

  publish topic/string value/ByteArray -> none
  static PUBLISH_INDEX ::= 0

  subscribe id/string -> none
  static SUBSCRIBE_INDEX ::= 1

  getMessage id/string -> any
  static GETMESSAGE_INDEX ::= 2

  mqttLog message/string id/string  -> none
  static MQTTLOG_INDEX ::= 3

//----------------------------------------------------------------------

class MQTTServiceClient extends services.ServiceClient implements MQTTService:
  static SELECTOR ::= MQTTService.SELECTOR
  name/string
  constructor .name selector/services.ServiceSelector=SELECTOR:
    assert: selector.matches SELECTOR
    super selector

  publish topic/string value/ByteArray -> none:
    invoke_ MQTTService.PUBLISH_INDEX [name + "/" + topic, value]

  subscribe id/string=name -> none:
    invoke_ MQTTService.SUBSCRIBE_INDEX [id]

  getMessage id/string=name -> any:
    return invoke_ MQTTService.GETMESSAGE_INDEX [id]

  mqttLog message/string id/string=name  -> none:
    invoke_ MQTTService.MQTTLOG_INDEX [name, json.encode message]


