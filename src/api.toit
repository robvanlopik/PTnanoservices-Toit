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

  subscribe -> none
  static SUBSCRIBE_INDEX ::= 1

  getMessage -> any
  static GETMESSAGE_INDEX ::= 2

  mqttLog message/string -> none
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

  subscribe  -> none:
    invoke_ MQTTService.SUBSCRIBE_INDEX [name]

  getMessage -> any:
    return invoke_ MQTTService.GETMESSAGE_INDEX [name]

  mqttLog message/string -> none:
    invoke_ MQTTService.MQTTLOG_INDEX [name, json.encode message]


