# 修改端口为20001列序
wget https://xgxray.oss-cn-hongkong.aliyuncs.com/YY/20001.sh
chmod +x 20001.sh
./20001.sh

find . -type f -name '*.json' -exec sed -i 's/20001/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20002/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20003/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20004/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20005/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20006/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20007/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20008/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20009/7878/g' {} +
find . -type f -name '*.json' -exec sed -i 's/20010/7878/g' {} +
