function SetZeroLevelImage(hObject, eventdata)

FA = guidata(hObject);

rect = round(getrect(gca));
area = double(FA.im(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3)));
% Calculate a mean height ot the selected area
zero_level = round(mean(area(:)));
% Modify the image and update it
FA.im = FA.im - zero_level;
FA.updateImage('PreserveView');

% Calculate surface roughness
roughness = sqrt(mean((area(:)-zero_level).^2))*FA.scaleZ;
msgbox(['RMS surface roughness = ', num2str(roughness), ' nm'], ...
    'Set Zero Level');

