clc; clear; close all;
warning off;

% Kiểm tra và tải mô hình ResNet50
if ~exist('resnet50', 'file')
    error('ResNet50 không có sẵn. Cài đặt bằng cách vào Add-On Explorer.');
end
net = resnet50;
inputSize = net.Layers(1).InputSize;

% Tải dữ liệu hình ảnh
imds = imageDatastore('FruitDataset', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Kiểm tra số lượng lớp trong dữ liệu
fruitClasses = categories(imds.Labels);
numClasses = numel(fruitClasses);
if numClasses < 2
    error('Cần ít nhất 2 lớp để huấn luyện.');
end

% Chuyển mô hình ResNet50 thành Layer Graph
lgraph = layerGraph(net);

% Xác định các lớp cần thay thế
lastLayer = 'fc1000';
softmaxLayerName = 'fc1000_softmax';
classLayerName = 'ClassificationLayer_fc1000';

% Xóa các lớp cuối cùng
lgraph = removeLayers(lgraph, {lastLayer, softmaxLayerName, classLayerName});

% Tạo lớp Fully Connected mới
newFC = fullyConnectedLayer(numClasses, 'Name', 'fc_new', ...
    'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10);

% Tạo lớp Softmax và Classification mới
newSoftmaxLayer = softmaxLayer('Name', 'softmax_new');
newClassLayer = classificationLayer('Name', 'classOutput');

% Thêm các lớp mới vào Layer Graph
lgraph = addLayers(lgraph, [newFC, newSoftmaxLayer, newClassLayer]);

% Kiểm tra kết nối trước khi thêm để tránh lỗi "Unable to add a connection that already exists"
connections = lgraph.Connections;

if ~any(strcmp(connections.Source, 'avg_pool') & strcmp(connections.Destination, 'fc_new'))
    lgraph = connectLayers(lgraph, 'avg_pool', 'fc_new');
end
if ~any(strcmp(connections.Source, 'fc_new') & strcmp(connections.Destination, 'softmax_new'))
    lgraph = connectLayers(lgraph, 'fc_new', 'softmax_new');
end
if ~any(strcmp(connections.Source, 'softmax_new') & strcmp(connections.Destination, 'classOutput'))
    lgraph = connectLayers(lgraph, 'softmax_new', 'classOutput');
end

% Kiểm tra lại mô hình
analyzeNetwork(lgraph);

% Định nghĩa lại ReadFcn để đảm bảo kích thước ảnh đúng
imds.ReadFcn = @(x) imresize(imread(x), inputSize(1:2));

% Chia dữ liệu thành tập huấn luyện (80%) và kiểm tra (20%)
[trainImds, testImds] = splitEachLabel(imds, 0.8, 'randomized');

% Cấu hình tham số huấn luyện
options = trainingOptions('adam', ...
    'MiniBatchSize', 16, ...
    'MaxEpochs', 20, ...
    'InitialLearnRate', 1e-4, ...
    'Plots', 'training-progress', ...
    'ValidationData', testImds, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', true);

% Huấn luyện mạng
fruitNet = trainNetwork(trainImds, lgraph, options);

% Lưu mô hình đã huấn luyện
save('fruitNet.mat', 'fruitNet');
disp('✅ Mô hình ResNet50 đã huấn luyện xong và được lưu!');
