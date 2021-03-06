function p = ViewProperties
ph = 144; % panel height
pTitle = 'View Properties';
pTag = 'ViewProperties';
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Visible', 'off', ...
    'Title', pTitle, ...
    'Tag', pTag, ...
    'Position', [0 0 230 ph]);
FA = guidata(gcf);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'HitTest', 'off', ...
    'Callback', @(h,ed) FA.hidePanel(pTag), ...
    'Position', [211 ph-30 18 16]);
% Panel components --------------------------------------------------------
% Captions
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Object               Color   Style           Width', ...
    'Position', [10 ph-38 215 14]);
% Fiber
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Fiber:', ...
    'Position', [10 ph-61 75 14]);
uicontrol(p, 'Style', 'pushbutton', ...
    'BackgroundColor', FA.fiberColor, ...
    'Tag', 'fiber', ...
    'Callback', @ViewProperties_ChangeColor, ...
    'Position', [85 ph-63 30 18]);
uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'line|points', ...
    'Value', FA.fiberStyle, ...
    'Tag', 'fiber', ...
    'Callback', @ViewProperties_ChangeStyle, ...
    'Position', [120 ph-65 52 22]);
uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '1|2|3|4|5|6|7', ...
    'Value', FA.fiberWidth, ...
    'Tag', 'fiber', ...
    'Callback', @ViewProperties_ChangeWidth, ...
    'Position', [177 ph-65 35 22]);
% Selected fiber
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Selected fiber:', ...
    'Position', [10 ph-84 100 14]);
uicontrol(p, 'Style', 'pushbutton', ...
    'BackgroundColor', FA.selFiberColor, ...
    'Tag', 'selected_fiber', ...
    'Callback', @ViewProperties_ChangeColor, ...
    'Position', [85 ph-86 30 18]);
uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'line|points', ...
    'Value', FA.selFiberStyle, ...
    'Tag', 'selected_fiber', ...
    'Callback', @ViewProperties_ChangeStyle, ...
    'Position', [120 ph-88 52 22]);
uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '1|2|3|4|5|6|7', ...
    'Value', FA.selFiberWidth, ...
    'Tag', 'selected_fiber', ...
    'Callback', @ViewProperties_ChangeWidth, ...
    'Position', [177 ph-88 35 22]);
% Mask line
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Mask line:', ...
    'Position', [10 ph-107 100 14]);
uicontrol(p, 'Style', 'pushbutton', ...
    'BackgroundColor', FA.maskLineColor, ...
    'Tag', 'mask_line', ...
    'Callback', @ViewProperties_ChangeColor, ...
    'Position', [85 ph-109 30 18]);
uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '1|2|3|4|5|6|7', ...
    'Value', FA.maskLineWidth, ...
    'Tag', 'mask_line', ...
    'Callback', @ViewProperties_ChangeWidth, ...
    'Position', [177 ph-111 35 22]);
% Scale bar
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Scale bar:', ...
    'Position', [10 ph-130 100 14]);
uicontrol(p, 'Style', 'pushbutton', ...
    'BackgroundColor', FA.scaleBarColor, ...
    'Tag', 'scale_bar', ...
    'Callback', @ViewProperties_ChangeColor, ...
    'Position', [85 ph-132 30 18]);
uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '1|2|3|4|5|6|7', ...
    'Value', FA.scaleBarWidth, ...
    'Tag', 'scale_bar', ...
    'Callback', @ViewProperties_ChangeWidth, ...
    'Position', [177 ph-134 35 22]);

function ViewProperties_ChangeColor(hObject, eventdata)
FA = guidata(hObject);
switch get(hObject, 'Tag')
    case 'fiber'
        FA.fiberColor = uisetcolor(FA.fiberColor);
        set(hObject, 'BackgroundColor', FA.fiberColor);
    case 'selected_fiber'
        FA.selFiberColor = uisetcolor(FA.selFiberColor);
        set(hObject, 'BackgroundColor', FA.selFiberColor);
    case 'mask_line'
        FA.maskLineColor = uisetcolor(FA.maskLineColor);
        set(hObject, 'BackgroundColor', FA.maskLineColor);
    case 'scale_bar'
        FA.scaleBarColor = uisetcolor(FA.scaleBarColor);
        set(hObject, 'BackgroundColor', FA.scaleBarColor);
end

set(FA.fibLine, 'Color', FA.fiberColor);
if FA.sel ~= 0
    set(FA.fibLine(FA.sel), 'Color', FA.selFiberColor);
end
set(FA.maskLine, 'EdgeColor', FA.maskLineColor);

function ViewProperties_ChangeStyle(hObject, eventdata)
FA = guidata(hObject);
switch get(hObject, 'Tag')
    case 'fiber'
        FA.fiberStyle = get(hObject, 'Value');
    case 'selected_fiber'
        FA.selFiberStyle = get(hObject, 'Value');
end

switch FA.fiberStyle
    case 1 % 'line'
        set(FA.fibLine, 'Marker', 'none', 'LineStyle', '-');
    case 2 % 'points'
        set(FA.fibLine, 'Marker', '.', 'LineStyle', 'none');
end

if FA.sel ~= 0
    switch FA.selFiberStyle
        case 1 % 'line'
            set(FA.fibLine(FA.sel), 'Marker', 'none', 'LineStyle', '-');
        case 2 % 'points'
            set(FA.fibLine(FA.sel), 'Marker', '.', 'LineStyle', 'none');
    end
end

function ViewProperties_ChangeWidth(hObject, eventdata)
FA = guidata(hObject);
switch get(hObject, 'Tag')
    case 'fiber'
        FA.fiberWidth = get(hObject, 'Value');
    case 'selected_fiber'
        FA.selFiberWidth = get(hObject, 'Value');
    case 'mask_line'
        FA.maskLineWidth = get(hObject, 'Value');
    case 'scale_bar'
        FA.scaleBarWidth = get(hObject, 'Value');
end

set(FA.fibLine, 'LineWidth', FA.fiberWidth);
if FA.sel ~= 0
    set(FA.fibLine(FA.sel), 'LineWidth', FA.selFiberWidth);
end
set(FA.maskLine, 'LineWidth', FA.maskLineWidth);

