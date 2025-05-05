sudo ./appd install java -i inventory --auto-start -q ssh -m visits-service
sudo ./appd configure smartagent --attach-configure-file /home/cisco/spring-petclinic-microservices/deployments/appdcli/lib/ld_preload.json -i inventory -q ssh -m visits-service --extra-vars "linux_config_path=/opt/appdynamics"
