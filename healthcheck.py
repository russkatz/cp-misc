#!/usr/local/bin/python3

from confluent_kafka import Producer, Consumer, KafkaError
import time

#alert after this many seconds of no messages on topic
alertseconds = 5
#topic to monitor
monitortopic = 'irc'
#topic to send alert events to
alerttopic = 'alerts'

consumer_settings = {
    'bootstrap.servers': 'node1:9092',
    'group.id': 'test1',
    'enable.auto.commit': False,
    'session.timeout.ms': 6000,
    'queue.buffering.max.messages': 10000000,
    'default.topic.config': {'auto.offset.reset': 'latest'}
}
producer_settings = {
    'bootstrap.servers': 'node1:9092',
    'linger.ms': 1000,
    'acks': 1
}

c = Consumer(consumer_settings)
p = Producer(producer_settings)

#Check current time in epoch seconds
lastmsg = int(time.time())

#Connect to topic to monitor
c.subscribe([monitortopic])

#This var just tracks if an alert was sent yet to prevent spamming the alerttopic
alerted = 0

try:
    while True:
        msg = c.poll(0.1)
        if msg is None:
            #Get the seconds elapsed since the last message (or since the application started if this is the first iteration through)
            lastmsgdelay = int(time.time()) - lastmsg
            #debug printing for me :)
            print(lastmsgdelay)
            #If the last message was longer than the alertseconds threshhold fire out an alert if no alert has been sent out yet
            if lastmsgdelay > alertseconds:
               if alerted == 0 :
                 msg = 'No msgs from %s for %s seconds' %(monitortopic,lastmsgdelay)
                 #More debug printing for me :)
                 print(msg)
                 p.produce(alerttopic, key='', value=msg )
                 #Set that an alert was sent for this violation
                 alerted = 1
            continue
        else:
            #This gets hit if there is a message received. Resets the lastmsg time to the current time
            lastmsg = int(time.time())
            #Send a second alert if this message clears a violation
            if alerted == 1:
                msg = 'Msgs received from %s after %s seconds' %(monitortopic,lastmsgdelay)
                #More debug printing for me :)
                print(msg)
                p.produce(alerttopic, key='', value=msg )
                #Clear the violation
                alerted = 0
            continue

except KeyboardInterrupt:
    pass

finally:
    c.close()
