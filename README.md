# dns-desec-script
Scripts for managing my [deSEC](https://desec.io) name server

## desec-updater
The location of the server for three domains has a somwhat dynamic IP (homelab setting), there a script runs as a cronjob to check whether the IP in the DNS server is still accurate. A configuration file takes a TOKEN and a definition of domains and the script itself should be run via CRON and keep the DNS settings up to date.
