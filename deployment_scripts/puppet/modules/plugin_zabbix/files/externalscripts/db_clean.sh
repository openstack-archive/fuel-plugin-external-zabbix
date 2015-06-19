#!/bin/bash
#
#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
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
