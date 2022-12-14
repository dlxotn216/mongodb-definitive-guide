#!/bin/bash

mongosh <<EOF
rsconf = {
  _id: 'mdbdefGuide',
  members: [
    {_id:  0, host:  'mongo-1:27017', priority: 2},
    {_id:  1, host:  'mongo-2:27018', priority: 1},
    {_id:  2, host:  'mongo-3:27019', priority: 1},
  ]
}
rs.initiate(rsconf);
rs.status();
EOF
