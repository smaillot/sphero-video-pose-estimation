pose_log = [];
px_log = [];
cam_url = 'http://192.168.1.27:8080/video';
cam = set_camera(cam_url);
tic;
% imshow(snapshot(cam))
w = waitbar(0);

%% Choose duration in seconds
%%%%%%%%%%%%%%%%%%%
duration = 5;
%%%%%%%%%%%%%%%%%%%

while toc < duration
    % hold off;
    % imshow(snapshot(cam));
    % hold on;
    [pose, ~] = get_position(cam);
    %[pose, px] = get_position(cam);
    pose_log = [pose_log [pose ; toc]];
    % px_log = [px_log px'];
    waitbar(toc/duration);
    % plot(px_log(1,:), px_log(2,:), 'g')
    % plot(px(1), px(2), '.r', 'MarkerSize', 15)
    % drawnow()
end
close(w)

disp(strcat(num2str(size(pose_log,2)), ' frames (',num2str(1/mean(diff(pose_log(3,:)))), ' fps)'))
subplot(211)
hold on;
plot(pose_log(3,:), pose_log(1,:), 'r')
plot(pose_log(3,:), pose_log(2,:), 'g')
legend('x','y')
xlabel('time (s)')
ylabel('position (cm)')
subplot(212)
hold on;
plot(pose_log(1,:), pose_log(2,:), 'g')
plot(pose_log(1,:), pose_log(2,:), '.r', 'MarkerSize', 15)
xlabel('x position')
ylabel('y position')
axis equal


function cam = set_camera(cam_url)
    if evalin( 'base', 'exist(''cam'',''var'') == 1' )
        cam = evalin('base','cam');
    else
        cam = ipcam(cam_url);
    end
end