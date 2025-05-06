sudo ./appd install smartagent -i inventory --auto-start -q ssh -u http://0.0.0.0:8000/appdsmartagent_64_linux_25.4.0.1247.zip   -vvvv
sudo ./appd configure smartagent -i inventory --attach-configure-file lib/ld_preload.json -q ssh -m visits-service 
