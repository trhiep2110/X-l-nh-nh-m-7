clc; clear; close all;
warning off;

% Tạo thư mục chứa dữ liệu
dataset_folder = 'FruitDataset';
if ~exist(dataset_folder, 'dir')
    mkdir(dataset_folder);
end

% Nhập thông tin hoa quả mới
fruit_name = input('Nhập tên loại hoa quả: ', 's');

% Chọn ảnh từ thư mục
[filename, pathname] = uigetfile({'*.jpg;*.png'}, 'Chọn ảnh hoa quả');
if isequal(filename, 0)
    disp('❌ Không có ảnh được chọn.');
    return;
end
img_path = fullfile(pathname, filename);

% Tạo thư mục theo tên hoa quả
fruit_folder = fullfile(dataset_folder, fruit_name);
if ~exist(fruit_folder, 'dir')
    mkdir(fruit_folder);
end

% Lưu ảnh vào thư mục
new_img_name = sprintf('%s_%s.jpg', fruit_name, datestr(now, 'yyyymmdd_HHMMSS'));
copyfile(img_path, fullfile(fruit_folder, new_img_name));

disp('✅ Ảnh hoa quả đã được lưu vào dataset!');
