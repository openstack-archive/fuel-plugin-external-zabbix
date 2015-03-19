#!/bin/bash
mysql zabbix -e "
update triggers set value=0,error='' where triggerid in (
    select ee.objectid from events ee
    inner join
        (select objectid,MAX(eventid) as maxid
        from events
        group by objectid)
    ee2 on ee.objectid=ee2.objectid and ee.eventid=ee2.maxid
    where
    ee.acknowledged=1) and value=1 and description in ('SNMPtrigger Critical: {ITEM.VALUE1}', 'SNMPtrigger Error: {ITEM.VALUE1}', 'SNMPtrigger Warning: {ITEM.VALUE1}', 'SNMPtrigger Information: {ITEM.VALUE1}');"
