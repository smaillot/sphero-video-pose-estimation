function cam = init_ipcam()

    default_URL = '192.168.43.1';
    cam_url = inputdlg('IP address', 'IP address', 1, {default_URL});
    
    port = '8080';
    cam = ipcam(strcat('http://', cam_url, ':', port, '/video'));
    
end