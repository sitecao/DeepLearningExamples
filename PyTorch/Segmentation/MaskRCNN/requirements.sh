
WORK_DIR=`mktemp -d`

pip install ninja yacs cython matplotlib tqdm opencv-python
cd $WORK_DIR
git clone https://github.com/NVIDIA/apex; cd apex;
python setup.py install --cuda_ext --cpp_ext
cd $WORK_DIR
git clone https://github.com/cocodataset/cocoapi.git; cd cocoapi/PythonAPI;
python setup.py build_ext install
cd /shared/DeepLearningExamples/PyTorch/Segmentation/MaskRCNN/pytorch/
python setup.py build develop

rm -rf $WORK_DIR