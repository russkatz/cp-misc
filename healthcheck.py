#!/usr/local/bin/python3

from confluent_kafka import Producer, Consumer, KafkaError
import time

#alert after this many seconds of no messages on topic
alertseconds = 5
monitortopic = 'irc'
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

lastmsg = int(time.time())

c.subscribe([monitortopic])
alerted = 0

try:
    while True:
        msg = c.poll(0.1)
        if msg is None:
            lastmsgdelay = int(time.time()) - lastmsg
            print(lastmsgdelay)
            if lastmsgdelay > alertseconds:
               if alerted == 0 :
                 msg = 'No msgs from %s for %s seconds' %(monitortopic,lastmsgdelay)
                 print(msg)
                 p.produce(alerttopic, key='', value=msg )
                 alerted = 1
            continue
        else:
            lastmsg = int(time.time())
            alerted = 0
            continue

except KeyboardInterrupt:
    pass

finally:
    c.close()
