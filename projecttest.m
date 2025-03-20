clc; clear; close all;
warning off;

% Load mô hình đã huấn luyện
load('fruitNet.mat');

% Khởi tạo webcam
cam = webcam;

% Kích thước đầu vào của mô hình
inputSize = fruitNet.Layers(1).InputSize(1:2);

disp('📸 Đưa một quả vào khung hình, nhấn phím bất kỳ để nhận diện...');

figure;
while true
    % Chụp ảnh từ webcam
    img = snapshot(cam);

    % Xử lý ảnh
    img_resized = imresize(img, inputSize);

    % Đảm bảo ảnh có 3 kênh màu RGB
    if size(img_resized, 3) == 1
        img_resized = cat(3, img_resized, img_resized, img_resized);
    end

    % Hiển thị ảnh trực tiếp từ camera
    imshow(img);
    title('Đưa quả vào khung hình - Nhấn phím để nhận diện', 'FontSize', 14);

    % Chờ người dùng nhấn phím để nhận diện
    pause;
    
    % Nhận diện loại quả
    label = classify(fruitNet, img_resized);

    % Hiển thị kết quả
    imshow(img);
    title(['✅ Loại quả nhận diện: ', char(label)], 'FontSize', 14, 'Color', 'red');
    disp(['✅ Loại quả nhận diện: ', char(label)]);

    % Thoát nếu nhấn phím ESC
    if waitforbuttonpress && strcmp(get(gcf, 'CurrentCharacter'), char(27))
        disp('🔴 Thoát nhận diện.');
        break;
    end
end

% Đóng webcam
clear cam;
close all;
