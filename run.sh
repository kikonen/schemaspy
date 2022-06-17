#!/bin/bash
# http://schemaspy.sourceforge.net
#APP_DIR=`dirname $0`
APP_DIR=$( cd "$(dirname "$0")" ; pwd -P )

. $APP_DIR/.env

if [[ $DB_HOST == "" ]]; then
    DB_HOST=$DEFAULT_DB_HOST
fi

if [[ $DB_PORT == "" ]]; then
    DB_PORT=$DEFAULT_DB_PORT
fi

if [[ $DB_USER == "" ]]; then
    DB_USER=$DEFAULT_DB_USER
fi

if [[ $DB_PASSORD == "" ]]; then
    DB_PASSWORD=$DEFAULT_DB_PASSWORD
fi

if [[ $DB_LIST == "" ]]; then
    DB_LIST=$DEFAULT_DB_LIST
fi


export PGPASSWORD=$DB_PASSWORD

echo "SEE: http://schemaspy.sourceforge.net"

while getopts ":u:p:" o; do
    case "${o}" in
        u)
            login=${OPTARG}
            ;;
        p)
            pwd=${OPTARG}
            ;;
        *)
            ;;
    esac
done
shift $((OPTIND-1))

DB_LIST=$1
DST_DIR=$2

if [[ $DB_LIST == '' || $DST_DIR == '' ]]; then
    echo "USAGE:"
    echo "DB_HOST=localhost DB_PORT=5432 ./run.sh [-u dbuser] [-p dbpassword] [db1,db2,..] [output_base_dir]"
    echo "all = $DEFAULT_DB_LIST"
    exit 1
fi

if [[ $DB_LIST == 'all' ]]; then
    DB_LIST=$DEFAULT_DB_LIST
fi

if [ "x$login" == "x" ]; then
    echo -n "login: "
    read login
fi

#if [ "x$pwd" == "x" ]; then
#    echo -n "password: "
#    read -s pwd
#    echo ""
#fi

mkdir -p $DST_DIR
cp -a $APP_DIR/index.html $DST_DIR

# avoid globbing (expansion of *).
set -f
array=(${DB_LIST//,/ })
for i in "${!array[@]}"; do
    db=${array[i]}
    echo "Generate schema: $db"
    cmd="java -jar $APP_DIR/schemaspy-6.1.0.jar -dp $APP_DIR/postgresql-42.3.5.jar -imageformat png -norows -t pgsql -host $DB_HOST -port $DB_PORT -u $login -pfp -db $db -s public -rails -o ${DST_DIR}/${db}_schema"
    echo "--------------------"
    echo $cmd
    echo "--------------------"
    $cmd
#    echo $pwd
done
