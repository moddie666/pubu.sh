#!/bin/bash
#
#pubu.sh
#

DEPS="curl jq"
for d in $DEPS
do if [ "x$(which $d)" = "x" ]
   then missing+=" $d"
   fi
done
if [ "x$missing" != "x" ]
then echo "Missing dependency:$missing!"
     exit 1
fi
ME=$(basename $0)
USAGE="# SEND MESSAGE VIA PUSHBULLET API
USAGE: $ME <command> <access token> [title] [message]
COMMANDS:
             h(elp) ... show this text
          d(evices) ... list devices
             p(ush) ... push a message"

pushes(){
   if [ "x$1" = "x" ] || [ "x$2" = "x" ] || [ "x$3" = "x" ]
   then echo -e "Missing data.\n$USAGE"
        exit 1
   fi
   TOK="$1"
   TITLE="$(jq -Rsa <<< "$2")"
   BODY="$(jq -Rsa <<< "$3")"
   curl -s --header "Access-Token: $TOK" \
        --header 'Content-Type: application/json' \
        --data-binary "{\"body\":$BODY,\"title\":$TITLE,\"type\":\"note\"}" \
        --request POST \
        https://api.pushbullet.com/v2/pushes | jq -r
}

devices(){
   if [ "x$1" = "x" ]
   then echo "Missing access token."
        exit 1
   fi
   TOK="$1"
   curl -s --header "Access-Token: $TOK" \
        https://api.pushbullet.com/v2/devices | jq -r '.devices[] | {iden: .iden, nick: .nickname}'
}


case $1 in
                          h|he|hel|help) echo "$USAGE"
                                         exit 0;;
     d|de|dev|devi|devic|device|devices) shift
                                         devices "$@";;
                          p|pu|pus|push) shift
                                         pushes "$@";;
                                      *) echo "Unknown Command: $@"
                                         echo "Use '$ME help' to show usage."
                                         exit 1;;
esac

