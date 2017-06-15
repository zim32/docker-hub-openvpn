#!/usr/bin/env bash

function test_inited {
    if [ -d "/etc/openvpn/keys/server" ]
        then return 0;
        else return 1;
    fi
}



if test_inited
then
    echo "inited"
    service openvpn start

    if [ "$ALLOW_INET" == "true" ]
    then
        iptables -t nat -A POSTROUTING -s "$OPENVPN_NET_ADDR"/"$OPENVPN_NET_MASK" -o eth0 -j MASQUERADE
    fi

else
    echo "You need init container to start openvpn service. Execute initvpn command first"
fi

tail -f /dev/null