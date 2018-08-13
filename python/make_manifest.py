#!/usr/bin/python
# -*- coding:utf-8 -*-

import os  
import hashlib  
import time  
import json
import collections

packageUrl = "http://192.168.2.50/version/"
remoteVersionUrl = "http://192.168.2.50/manifest/version.manifest"
remoteManifestUrl = "http://192.168.2.50/manifest/project.manifest"
engineVersion = "Cocos2d-x v3.x"

resource_path = os.getcwd()
output_path = os.path.join(os.getcwd(), 'manifest11')

IGNORED_FILE_LIST = ['res/project.manifest', 'src/channelId.luac']

def gen_md5(filename):  
    if not os.path.isfile(filename):  
        return  
    md5 = hashlib.md5() # create a md5 object  
    f = file(filename, 'rb')  
    while True:  
        b = f.read(8096) # get file content.  
        if not b:  
            break  
        md5.update(b) # encrypt the file  
    f.close()  
    return md5.hexdigest()  

def is_ignored_file(filename):
    for each in IGNORED_FILE_LIST:
        if filename == each:
            return True
    return False
    
def walk(path, prefix):  
    fl = os.listdir(path) # get what we have in the dir.  
    for f in fl:  
        if os.path.isdir(os.path.join(path, f)): # if is a dir.  
            if prefix == '':  
                walk(os.path.join(path, f), f)  
            else:  
                walk(os.path.join(path, f), prefix + '/' + f)  
        else:  
            file_path = prefix + '/' + f
            if not is_ignored_file(file_path):
                root_dict["assets"][file_path] = {"md5" : gen_md5(os.path.join(path, f))}

if __name__ == "__main__":   
    timeStr = time.strftime("%Y%m%d%H%M%S", time.localtime(time.time()))  
    if not os.path.exists(output_path):  
        os.mkdir(output_path)

    # generate manifest  
    global root_dict
    root_dict = collections.OrderedDict()
    
    root_dict["packageUrl"] = packageUrl
    root_dict["remoteVersionUrl"] = remoteVersionUrl
    root_dict["remoteManifestUrl"] = remoteManifestUrl
    root_dict["version"] = "0.0.%s" %timeStr
    root_dict["engineVersion"] = engineVersion
    
    # generate version.manifest  
    f = file(os.path.join(output_path, "version.manifest"), "w+")  
    f.write(json.dumps(root_dict, indent = 4))
    f.close()
    
    root_dict["assets"] = collections.OrderedDict()
    root_dict["searchPaths"] = []
    
    walk(resource_path + '/src', 'src')
    walk(resource_path + '/res', 'res')

    # generate project.manifest  
    f = file(os.path.join(output_path, "project.manifest"), "w+")  
    f.write(json.dumps(root_dict, indent = 4))
    f.close()
    
    print 'generate version.manifest and project.manifest finished.'
