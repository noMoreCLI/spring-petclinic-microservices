console.log("agent.js loaded");

window["adrum-start-time"] = new Date().getTime();
(function(config){
    config.appKey = "AD-AAB-ADY-VGC";
    config.adrumExtUrlHttp = "http://cdn.appdynamics.com";
    config.adrumExtUrlHttps = "https://cdn.appdynamics.com";
    config.beaconUrlHttp = "http://pdx-col.eum-appdynamics.com";
    config.beaconUrlHttps = "https://pdx-col.eum-appdynamics.com";
    config.useHTTPSAlways = true;
    config.xd = {"enable":true};
    config.resTiming = {"sampler":"RelevantN","maxNum":20,"bufSize":200,"clearResTimingOnBeaconSend":true};
    config.maxUrlLength = 512;
    config.spa = {"spa2":true};
    config.releaseId = "clus";
    config.enableCoreWebVitals = true;
    config.enableSpeedIndex = true;
})(window["adrum-config"] || (window["adrum-config"] = {}));
/*
(function loadExternalScript() {
  const script = document.createElement("script");
  script.src = "//cdn.appdynamics.com/adrum/adrum-24.4.0.4454.js"; // URL of the external script
  script.async = true; // Load the script asynchronously (optional, but recommended)
  document.head.appendChild(script); // Append the script to the <head> of the document

  script.onload = function () {
    console.log("External script loaded successfully!");
    // You can now use the functionality provided by the loaded script
  };

  script.onerror = function () {
    console.error("Failed to load the external script.");
  };
})(); */