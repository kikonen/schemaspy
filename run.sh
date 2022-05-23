#!/bin/bash
# http://schemaspy.sourceforge.net
#APP_DIR=`dirname $0`
APP_DIR=$( cd "$(dirname "$0")" ; pwd -P )

. $APP_DIR/.env

db_host=localhost
db_port=5433

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

DBS=$1
DST_DIR=$2

if [[ $DBS == '' || $DST_DIR == '' ]]; then
    echo "USAGE:"
    echo "./run.sh [-u dbuser] [-p dbpassword] [db1,db2,..] [output_base_dir]"
    echo "all = $ALL_DBS"
    exit 1
fi

if [[ $DBS == 'all' ]]; then
    DBS=$ALL_DBS
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
array=(${DBS//,/ })
for i in "${!array[@]}"; do
    db=${array[i]}
    echo "Generate schema: $db"
    cmd="java -jar $APP_DIR/schemaspy-6.1.0.jar -dp $APP_DIR/postgresql-42.3.5.jar -imageformat png -norows -t pgsql -host $db_host -port $db_port -u $login -pfp -db $db -s public -o ${DST_DIR}/${db}_schema"
#    echo $cmd
    $cmd
#    echo $pwd
done
