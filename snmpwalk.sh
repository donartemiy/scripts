#!/bin/bash
# description sw-core(peripherals)
# description dts-sw-dl-mp33-peripherals
echo "dts-sw-dl-mp33-peripherals"
snmpwalk -v 2c -c public 10.0.1.25 1.3.6.1.2.1.1.3
snmpwalk -v 2c -c public 10.0.1.26 1.3.6.1.2.1.1.3
snmpwalk -v 2c -c public 10.0.1.97 1.3.6.1.2.1.1.3

# description dts-sw-dl-n20-peripherals
echo "dts-sw-dl-n20-peripherals"
snmpwalk -v 2c -c public 10.0.2.33 1.3.6.1.2.1.1.3
snmpwalk -v 2c -c public 10.0.2.34 1.3.6.1.2.1.1.3
snmpwalk -v 2c -c public 10.0.2.1 1.3.6.1.2.1.1.3
