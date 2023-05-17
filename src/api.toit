// Author: Rob van Lopik
// License: MIT
// inspired by githun:/kasperl//

import system.services

interface MQTTService:
  static SELECTOR ::= services.ServiceSelector
      --uuid="abacadabra"
      --major=1
      --minor=0

  publish topic/string value/ByteArray -> none
  static PUBLISH_INDEX ::= 0

// to be added:
// methods for subscribing and mechanism for receiving messages

class MQTTServiceClient extends services.ServiceClient implements MQTTService:
  static SELECTOR ::= MQTTService.SELECTOR
  name/string
  constructor .name selector/services.ServiceSelector=SELECTOR:
    assert: selector.matches SELECTOR
    super selector

  publish topic/string value/ByteArray -> none:
    invoke_ MQTTService.PUBLISH_INDEX [name + "/" + topic, value]


