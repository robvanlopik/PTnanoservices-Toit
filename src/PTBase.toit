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
  from_prefix := "PT/from:$DeviceName"
  to_prefix := "PT/to:$DeviceName"

  transport := mqtt.TcpTransport net.open --host=Broker
  print "starting client"
  Messenger := mqtt.Client --transport=transport  // --routes=RouteMap
  print "Connected to MQTT Broker @ $Broker:$Port"
  Messenger.start --client_id=ClientID
  print "client $ClientID started"
  Messenger.publish "$from_prefix/SYS" (json.encode "Messenger started")
  print "MQTT service provider started"
  service := MQTTServiceProvider Messenger from_prefix
  service.install
  print "MQTT service provider should now be running"
// here we should start listening
  Messenger.subscribe "$to_prefix/#":: | topic data |
    print "$topic $data"
    processToMessage topic data service
  print "started listening to $to_prefix"
// processing incoming messages
processToMessage topic data mservice:
  topicList := topic.split "/"
  // remove first two (PT and devicename)
  topicList = topicList[2..].copy
  if topicList[0] == "SYS": 
    processSYS topicList data
  else:
    mservice.newMessage topicList[0] [topicList[1..], data]

processSYS tList data:
  print "SYS request $tList with data $data"



//---------------------------------------------
// service provider. uses Messenger to send messages
// and receives messages to be retrieved by client (indexed by service name)
//
class MQTTServiceProvider extends ServiceProvider
  implements ServiceHandler: 
//    implements MQTTService ServiceHandler:
  broker_/mqtt.Client
  prefix_/string
  directory := {:}
  constructor .broker_ .prefix_:
    super "mqtt" --major=1 --minor=0
    provides MQTTService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == MQTTService.PUBLISH_INDEX: return publish arguments[0] arguments[1]
    if index == MQTTService.SUBSCRIBE_INDEX: return subscribe arguments[0]
    if index == MQTTService.GETMESSAGE_INDEX: return getMessage arguments[0]
    if index == MQTTService.MQTTLOG_INDEX: return mqttLog arguments[0] arguments[1]
    unreachable

  publish topic data -> none:
    print "$(%08d Time.monotonic_us): $topic - $data"
    broker_.publish "$prefix_/$topic" data
  
  subscribe name:
    directory[name] = null

// in the following name = serviceName is the third part of the topic
// msg is a list containing the remaining topic items as list, and data as byteArray
  getMessage name/string:
    msg := directory.get name
    if msg != null : directory[name] = null
   // print "found message $msg"
    return msg

  newMessage serviceName/string msg/List:
    directory[serviceName] = msg
  
  mqttLog name/string message/string  :
    broker_.publish (prefix_ + "/" + name) (json.encode message)
  
  


  
