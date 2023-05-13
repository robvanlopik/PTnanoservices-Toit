// Author: Rob van Lopik
// License: MIT

import net
import mqtt
import encoding.json
import encoding.base64
import encoding.tison
import device
import system.assets
import .api show *
import system.services show *
VERSION ::= "0.1"

Broker := "test.mosquitto.org"
DeviceName := "test1"
Port := 1883
ClientID := "$device.name"


main:
  print "PTBase started"

  defines := assets.decode.get "jag.defines"
      --if_present=: tison.decode it
      --if_absent=: {:}
  if defines is not Map:
    print "defines are malformed"

  defines.get "broker"
      --if_present=: Broker = it
  defines.get "name"
      --if_present=: DeviceName = it

  print "Broker is $Broker and Name is $DeviceName"
  prefix := "PT/$DeviceName"

  transport := mqtt.TcpTransport net.open --host=Broker
  print "starting client"
  Messenger := mqtt.Client --transport=transport  // --routes=RouteMap
  print "Connected to MQTT Broker @ $Broker:$Port"
  Messenger.start --client_id=ClientID
  print "client $ClientID started"
  Messenger.publish "$prefix/SYS" (json.encode "Messenger started")
  print "MQTT service provider started"
  service := MQTTServiceProvider Messenger prefix
  service.install
  print "MQTT service provider should now be running"

class MQTTServiceProvider extends ServiceProvider
    implements MQTTService ServiceHandler:
  broker_/mqtt.Client
  prefix_/string
  constructor .broker_ .prefix_:
    super "mqtt" --major=1 --minor=0
    provides MQTTService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == MQTTService.PUBLISH_INDEX: return publish arguments[0] arguments[1]
    unreachable

  publish topic data -> none:
    print "$(%08d Time.monotonic_us): $topic - $data"
    broker_.publish "$prefix_/$topic" data
