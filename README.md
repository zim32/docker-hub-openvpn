Yet another OpenVPN container. Designed to use bridged network mode.

#### General usage

Usage example using docker-compose

```
version: "2"
services:
  openvpn:
    image: zim32/openvpn:latest
    container_name: openvpn
    ports:
      - "1194:1194/udp"
    volumes:
      - /dev/tun:/dev/tun
    privileged: true
```

1) Modify env variables for your needs
* REMOTE_HOST - host users will connect to. Default: 127.0.0.1. **Change to your server IP**
* REMOTE_PORT - port users will connect to. Default: 1194
* OPENVPN_PROTO   - used protocol. Default: udp
* OPENVPN_PORT    - port openvpn will listen to. Default: 1194
* OPENVPN_DEV     - device mode. Default: tun
* OPENVPN_NET_ADDR  - vpn network ip.   Default: "10.8.0.0"
* OPENVPN_NET_MASK  - vpn network mask. Default: "255.255.255.0"
* ALLOW_INET      - whether to provide internet to clients. If true, init script will create needed iptables rules. Default: true

2) Run service

`docker-compose -f compose.yml up -d openvpn`

3) If you need custom certificate variables just copy original **/etc/openvpn/easy-rsa/vars** file, modify it and mount back to container

4) At first run you need to make some initialization in order to generate needed server certificates and process configuration files. Run:

`docker-compose -f compose.yml exec openvpn initvpn`

And complete all steps. After all you will see **DONE**. It means everything is good

5) Restart container. After this step openvpn will start listening to incoming connections

`docker-compose -f compose.yml restart openvpn`

You can verify openvpn started by running `docker-compose -f compose.yml logs openvpn`

6) Generate first user certificate
 
`docker-compose -f compose.yml exec openvpn usercert`
 
And complete all steps

7) Copy generated user certificate back to host

`docker cp openvpn:/etc/openvpn/keys/user.zip user.zip`

8) Copy user.zip to your local computer
 
9) Unpack it and use

`sudo openvpn --config config.ovpn`

If you need another user certificate just repeat steps 4-7. **Don't forget to change user name and email in generated certificate**

There are two important files: **/root/server.append.conf** and **/root/user.append.ovpn**. Content from this files is appended to
*/etc/openvpn/server.conf* and */root/user.template.ovpn* respectively **during step 3**. Use them (create and mount inside container) if you want to add some configuration to all your server or all clients configuration (f.e. to push custom routes etc.)

#### Profiles

There are also so called client **profiles**. They are located in folder /root/profiles/**profile_name**.ovpn, where profile_name is first argument of usercert command.
This files will be appended while generating client's certificates.
Two profiles exists by default: all-traffic and local-only.

The first one will redirect all client's traffic to OpenVPN server.  
The second one is for vpn network only.
 
You can mount /root/profiles folder and add custom profiles if you want.

#### Notes

Nothing is mounted by default in this container. So if you want to persist you configuration you can mount /etc/openvpn directory to persist container recreation.
But **keep this folder is a safe place** in this case.

By default client-to-client is disabled. If you need it use /root/server.append.conf file. Put "client-to-client" there.