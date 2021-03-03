# TechBot
## Hardware Testing Automation Script 
Current version 2.0 - 3/3/2021

Created to help automate some aspects of the hardware testing process/mass deployment of windows machines. 

Put it on a USB stick and run techbot_v2.bat on the target machine!

See example_log_file.txt to see how the script logs information. 

**Features**  
Automatically grabs and outputs machine specifications to a timestamped txt file, including:  
*Computer name  
Make/Model/Serial Number  
CPU/GPU/RAM/C:\ information  
Windows License status   
Wireless card info*  

Basic ping out to Google DNS for connectivity status. 

Opens several component tests:  
Youtube video for audio/speakers  
Mictest website for microphone testing  
Keyboard testing website for keyboard testing  
Windows camera app for camera testing 

When the script ends you can opt to reset Windows to factory setup
  
Deprecated features:  
*Automatically connect to specified WiFi SSID* - hard to do cleanly in batch, it worked but not 100%  
*Perflogs* - basic diagnostic tool but if you need to run diags just use the built in ones 
  
Features to implement:  
Spanning tree of options to select specific testing features  
Automated component testing  
Network based script deployment  
