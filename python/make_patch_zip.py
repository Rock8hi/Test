# -*- coding: utf-8 -*-

'''
1.将新旧两个版本的apk和此脚本放到同一个目录，
2.指定新旧两个版本apk的文件名字(OLD_APK, NEW_APK)
3.执行此脚本
4.压缩差异文件，将以当天日期为文件名生成zip文件
'''

import os
import time
import hashlib
import zipfile
import shutil

OLD_APK = 'YDCityLandTest001_7.1.0.apk'
NEW_APK = 'YDLand2WxGzh001_7.1.3.apk'

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


def main():
    if not os.path.exists(OLD_APK):
        print('old apk is not exists')
        return
    if not os.path.exists(NEW_APK):
        print('new apk is not exists')
        return
    if os.path.exists('temp'):
        shutil.rmtree('temp')
    old_assets = os.path.join('temp', 'old_apk')
    new_assets = os.path.join('temp', 'new_apk')
    print('uncompress apk')
    old_zip = zipfile.ZipFile(OLD_APK)
    old_zip.extractall(old_assets)
    new_zip = zipfile.ZipFile(NEW_APK)
    new_zip.extractall(new_assets)
    print('check diff assets')
    zip_filename = time.strftime('%Y%m%d')
    out_path = os.path.join('temp', zip_filename)
    walk(os.path.join(new_assets, 'assets', 'src'), out_path, old_assets, new_assets)
    walk(os.path.join(new_assets, 'assets', 'res'), out_path, old_assets, new_assets)
    print('diff files count:', diff_files_count)
    shutil.make_archive(zip_filename, 'zip', root_dir=out_path)
    shutil.rmtree('temp')
    print('finish，zip filename：', zip_filename + '.zip')


if __name__ == '__main__':
    main()
    os.system('pause')
