#!/usr/bin/env bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
        local var="$1"
        local fileVar="${var}_FILE"
        local def="${2:-}"
        if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
                echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
                exit 1
        fi
        local val="$def"
        if [ "${!var:-}" ]; then
                val="${!var}"
        elif [ "${!fileVar:-}" ]; then
                val="$(< "${!fileVar}")"
        fi
        export "$var"="$val"
        unset "$fileVar"
}

if [ "${1:0:1}" = '-' ]; then
        set -- agens "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'agens' ] && [ "$(id -u)" = '0' ]; then
        mkdir -p "$AGDATA"
        chown -R agens "$AGDATA"
        chmod 700 "$AGDATA"

        mkdir -p /var/run/agens
        chown -R agens /var/run/agens
        chmod 775 /var/run/agens

        # Create the transaction log directory before initdb is run (below) so the directory is owned by the correct user
        if [ "$AGENS_INITDB_XLOGDIR" ]; then
                mkdir -p "$AGENS_INITDB_XLOGDIR"
                chown -R agens "$AGENS_INITDB_XLOGDIR"
                chmod 700 "$AGENS_INITDB_XLOGDIR"
        fi

        exec gosu agens "$BASH_SOURCE" "agens"
fi

if [ "$1" = 'agens' ]; then
        mkdir -p "$AGDATA"
        chown -R "$(id -u)" "$AGDATA" 2>/dev/null || :
        chmod 700 "$AGDATA" 2>/dev/null || :

        # look specifically for PG_VERSION, as it is expected in the DB dir
        if [ ! -s "$AGDATA/PG_VERSION" ]; then
                file_env 'AGENS_INITDB_ARGS'
                if [ "$AGENS_INITDB_XLOGDIR" ]; then
                        export AGENS_INITDB_ARGS="$AGENS_INITDB_ARGS --xlogdir $AGENS_INITDB_XLOGDIR"
                fi
                eval "initdb --username=agens $AGENS_INITDB_ARGS"

                # check password first so we can output the warning before agens
                # messes it up
                file_env 'AGENS_PASSWORD'
                if [ "$AGENS_PASSWORD" ]; then
                        pass="PASSWORD '$AGENS_PASSWORD'"
                        authMethod=md5
                else
                        # The - option suppresses leading tabs but *not* spaces. :)
                        cat >&2 <<-'EOWARN'
                                ****************************************************
                                WARNING: No password has been set for the database.
                                         This will allow anyone with access to the
                                         Postgres port to access your database. In
                                         Docker's default configuration, this is
                                         effectively any other container on the same
                                         system.
                                         Use "-e AGENS_PASSWORD=password" to set
                                         it in "docker run".
                                ****************************************************
                        EOWARN

                        pass=
                        authMethod=trust
                fi

                {
                        echo
                        echo "host all all all $authMethod"
                } >> "$AGDATA/pg_hba.conf"

                # internal start of server in order to allow set-up using agens-client
                # does not listen on external TCP/IP and waits until start finishes
                AGUSER="${AGUSER:-agens}" \
                echo "$AGUSER test"
                ag_ctl -D "$AGDATA" \
                        -o "-c listen_addresses='localhost'" \
                        -w start

                file_env 'AGENS_USER' 'agens'
                        echo $AGENS_USER
                file_env 'AGENS_DB' "$AGENS_USER"
                        echo $AGENS_DB

                agens=( agens -v ON_ERROR_STOP=1 )

                if [ "$AGENS_DB" != 'agens' ]; then
                        "${agens[@]}" --username agens <<-EOSQL
                                CREATE DATABASE "$AGENS_DB" ;
                        EOSQL
                        echo
                fi

                if [ "$AGENS_USER" = 'agens' ]; then
                        op='ALTER'
                        echo
                else
                        op='CREATE'
                        echo
                fi
                "${agens[@]}" --username agens <<-EOSQL
                        $op USER "$AGENS_USER" WITH SUPERUSER $pass ;
                EOSQL
                echo

                agens+=( --username "$AGENS_USER" --dbname "$AGENS_DB" )

                echo
                for f in /docker-entrypoint-initdb.d/*; do
                        case "$f" in
                                *.sh)     echo "$0: running $f"; . "$f" ;;
                                *.sql)    echo "$0: running $f"; "${agens[@]}" -f "$f"; echo ;;
                                *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${agens[@]}"; echo ;;
                                *)        echo "$0: ignoring $f" ;;
                        esac
                        echo
                done

                AGUSER="${AGUSER:-agens}" \
                ag_ctl -D "$AGDATA" -m fast -w stop

                echo
                echo 'AGENSGRAPH init process complete; ready for start up.'
                echo
        fi
fi

exec "postgres"
