sudo ./appd install java -i inventory --auto-start -q ssh -m visits-service -a Petclinic-1 -n visits-service -t visits-service
sudo ./appd configure smartagent --attach-configure-file /home/cisco/spring-petclinic-microservices/deployments/appdcli/lib/ld_preload.json -i inventory -q ssh -m visits-service 
