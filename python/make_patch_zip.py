# -*- coding: utf-8 -*-

"""
新的差异补丁包是对比上次差异补丁包（或apk）基础上生成的
base.apk                             <> (src and res) > patch_1.zip
base.apk + patch_1.zip               <> (src and res) > patch_2.zip
base.apk + patch_1.zip + patch_2.zip <> (src and res) > patch_3.zip
...

因此打包前，必须准备有base.apk和之前的所有的差异补丁包
设置BASE_APK和OLD_PATCHES的路径，所有差异补丁包放到OLD_PATCHES路径下

差异补丁包在客户端使用流程:
客户端启动后请求web接口，按顺序依次下载并释放到缓存目录下，reload已加载的脚本，进入游戏

注意:
所有差异补丁包跟某个apk版本对应的。例如128版本apk的补丁包不能用在127或129版本的apk上。

========= 重要 =========
1. 确认BASE_APK是否正确
2. 确认OLD_PATCHES路径下所有差异补丁包是否齐全并与BASE_APK对应
3. 如果没有所有差异补丁包，可以到OSS上对应的版本下下载
4. 新的差异补丁包将以当天日期(20180808.zip)命名
"""

import os
import time
import hashlib
import zipfile
import shutil
import struct


# 某个apk版本的基础包路径
BASE_APK = 'D:/work/fish/develop/png/YDFish2_1.2.7.apk'
# 旧的差异补丁包路径
OLD_PATCHES = 'D:/work/fish/develop/patches/'


# ======================================================
# 压缩和加密资源相关设置
# ======================================================
# 是否需要压缩png资源（如果指定压缩后的资源，则无需重复压缩）
IS_COMPRESS_PNG = False

# pngquant.exe命令的路径
COMPRESS_CMD = 'D:/work/fish/develop/png/pngquant.exe'

# lua脚本路径
SRC_PATH = 'D:/work/fish/develop/src/'

# 资源路径（也可以指定为压缩后的路径，res_compressed）
RES_PATH = 'D:/work/fish/develop/res_compressed/'

# 加密图片资源的key
XOR_KEY = 0x67
# ======================================================


# 统计差异资源个数
diff_files_count = 0


def calc_file_md5(filename):
    if not os.path.isfile(filename):
        return
    if os.path.getsize(filename) > 8096:
        return _calc_large_file_md5(filename)
    return _calc_small_file_md5(filename)


def _calc_small_file_md5(filename):
    with open(filename, 'rb') as f:
        obj = hashlib.md5()
        obj.update(f.read())
        return obj.hexdigest()


def _calc_large_file_md5(filename):
    obj = hashlib.md5()
    with open(filename, 'rb') as f:
        while True:
            b = f.read(8096)
            if not b:
                break
            obj.update(b)
        return obj.hexdigest()


def fix_sep(path, sep):
    if path is None or type(path) != str:
        return path
    if sep is None or type(sep) != str or sep == '':
        return path
    if sep != '\\':
        return path.replace('\\', sep)
    if sep != '/':
        return path.replace('/', sep)
    return path


def check_dirs(file_path):
    file_path = fix_sep(file_path, os.sep)
    if os.path.exists(file_path):
        return
    if os.path.splitext(file_path)[1] != '':
        file_path = file_path[: file_path.rfind(os.sep)]
        if os.path.exists(file_path):
            return
    os.makedirs(file_path)


def walk(assets_dir, out_path, old_assets, new_assets):
    old_apk_prefix_len = len(old_assets)+1
    new_assets_prefix_len = len(os.path.join(new_assets, 'assets'))+1
    for f in os.listdir(assets_dir):
        ff = os.path.join(assets_dir, f)
        if os.path.isdir(ff):
            walk(ff, out_path, old_assets, new_assets)
        elif os.path.isfile(ff):
            fff = os.path.join(old_assets, ff[old_apk_prefix_len:])
            if not os.path.isfile(fff) or calc_file_md5(fff) != calc_file_md5(ff):
                global diff_files_count
                diff_files_count += 1
                out_file = os.path.join(out_path, ff[new_assets_prefix_len:])
                check_dirs(out_file)
                shutil.copyfile(ff, out_file)


def uncompress_old_patches(out_path):
    if not os.path.isdir(OLD_PATCHES):
        return
    patches = []
    for filename in os.listdir(OLD_PATCHES):
        fd = os.path.join(OLD_PATCHES, filename)
        if os.path.isfile(fd) and fd.endswith('.zip'):
            patches.append(fd)
    patches.sort()
    for fd in patches:
        print('unzip %s' % fd)
        old_zip = zipfile.ZipFile(fd)
        old_zip.extractall(out_path)


def main():
    if not os.path.exists(BASE_APK):
        print('base apk is not exists')
        return
    if os.path.exists('temp'):
        shutil.rmtree('temp')
    old_assets = os.path.join('temp', 'old_apk')
    new_assets = os.path.join('temp', 'new_apk')
    print('uncompress base apk')
    old_zip = zipfile.ZipFile(BASE_APK)
    old_zip.extractall(old_assets)
    print('uncompress old patches')
    uncompress_old_patches(os.path.join(old_assets, 'assets'))
    print('encrypt src and res')
    encrypt_assets()
    print('diff assets')
    zip_filename = time.strftime('%Y%m%d')
    out_path = os.path.join('temp', zip_filename)
    walk(os.path.join(new_assets, 'assets', 'src'), out_path, old_assets, new_assets)
    walk(os.path.join(new_assets, 'assets', 'res'), out_path, old_assets, new_assets)
    print('diff files count:', diff_files_count)
    shutil.make_archive(zip_filename, 'zip', root_dir=out_path)
    # shutil.rmtree('temp')
    print('finish，zip：', zip_filename + '.zip')


# 对数据做异或操作
def xor(data, key):
    ret = b''
    for i in range(0, len(data)):
        ret += struct.pack('=B', struct.unpack('=B', data[i * 1: (i * 1) + 1])[0] ^ key)
    return ret


# 对文件做异或操作
def xor_file(in_file_path, out_file_path):
    with open(in_file_path, 'rb') as rf:
        with open(out_file_path, 'wb') as wf:
            while True:
                chunk = rf.read(4096)
                if not chunk:
                    break
                wf.write(xor(chunk, XOR_KEY))


# 压缩png图片
def compress_png(file_path):
    os.system('"%s" --force --strip --skip-if-larger --ext .png "%s"' % (COMPRESS_CMD, file_path))


def encrypt_images(dir_path, in_root_path, out_root_path):
    for filename in os.listdir(dir_path):
        in_path = os.path.join(dir_path, filename)
        out_path = os.path.join(out_root_path, in_path[len(in_root_path):])
        if os.path.isdir(in_path):
            if not os.path.isdir(out_path):
                os.mkdir(out_path)
            encrypt_images(in_path, in_root_path, out_root_path)
        elif os.path.isfile(in_path):
            if filename.endswith(".jpg") or filename.endswith(".bmp"):
                print('xor %s' % in_path)
                xor_file(in_path, out_path)
            elif filename.endswith(".png"):
                if IS_COMPRESS_PNG:
                    tmp = os.path.join('temp', filename)
                    print('temp copy %s to %s' % (in_path, tmp))
                    shutil.copyfile(in_path, tmp)
                    print('compress %s' % tmp)
                    compress_png(tmp)
                    print('xor %s' % in_path)
                    xor_file(tmp, out_path)
                    print('remove %s' % tmp)
                    os.remove(tmp)
                else:
                    xor_file(in_path, out_path)
            else:
                print('copy %s' % in_path)
                shutil.copyfile(in_path, out_path)


# 加密图片资源
def encrypt_res():
    out_root_path = 'temp/new_apk/assets/res'
    check_dirs(out_root_path)

    global RES_PATH
    last_byte = RES_PATH[len(RES_PATH)-1:]
    if last_byte != '/' and last_byte != '\\':
        RES_PATH = RES_PATH + os.sep

    print('encrypt res start')
    encrypt_images(RES_PATH, RES_PATH, out_root_path)
    print('encrypt res finish')


# 加密lua脚本
def compile_lua():
    print('compile lua start')
    cocos_root = os.environ.get('COCOS_CONSOLE_ROOT')
    if cocos_root is None:
        print('COCOS_CONSOLE_ROOT is not exists.')
        return
    cocos = cocos_root + os.sep + 'cocos.bat'
    if not os.path.isfile(cocos):
        print('cocos.bat is not exists.')
        return
    cmd = '%s luacompile -s %s -d temp/new_apk/assets/src -e -k JQNET_Mobile_Key_Start201' \
          '60301 -b wwwPkpaiCom_Mobile_Sign_Start20160301 --disable-compile' % (cocos, SRC_PATH)
    print(os.popen(cmd).read())
    print('compile lua finish')


def encrypt_assets():
    encrypt_res()
    compile_lua()


if __name__ == '__main__':
    main()
    os.system('pause')
