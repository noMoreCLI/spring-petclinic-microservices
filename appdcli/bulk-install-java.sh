sudo ./appd install java -i inventory --auto-start -q ssh -m visits-service
sudo ./appd configure smartagent --attach-configure-file lib/ld_preload.json  -i inventory -q ssh -m visits-service 
