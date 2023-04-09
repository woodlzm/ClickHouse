#!/usr/bin/env bash

CUR_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
#  shellcheck source=../shell_config.sh
. "$CUR_DIR"/../shell_config.sh

user_files_path=$($CLICKHOUSE_CLIENT --query "select _path,_file from file('nonexist.txt', 'CSV', 'val1 char')" 2>&1 | grep -E '^Code: 107.*FILE_DOESNT_EXIST' | head -1 | awk '{gsub("/nonexist.txt","",$9); print $9}')

UNIQ_DEST_PATH=$user_files_path/test-02455-$RANDOM-$RANDOM
mkdir -p $UNIQ_DEST_PATH
cp "$CUR_DIR"/data_csv/10m_rows.csv.xz $UNIQ_DEST_PATH/

${CLICKHOUSE_CLIENT} --query="SELECT * FROM file('$UNIQ_DEST_PATH/10m_rows.csv.xz' , 'CSVWithNames') order by identifier, number, name, surname, birthday LIMIT 1 settings max_memory_usage=1000000000"
${CLICKHOUSE_CLIENT} --query="SELECT * FROM file('$UNIQ_DEST_PATH/10m_rows.csv.xz' , 'CSVWithNames') order by identifier, number, name, surname, birthday LIMIT 1 settings max_memory_usage=100000000"

rm -rf $UNIQ_DEST_PATH
