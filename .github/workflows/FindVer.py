# -*- coding: utf8 -*-
import os
import re 

ret = ''
prev = 0
comp = 0
strlen = 0
prevstr = ''
size = (os.popen('ls -d */ -l | grep ^d | wc -l')).read()
list = os.popen('ls -d */ -l | awk \'{print $9}\'').read()
arr = list.strip().split('/\n')

ret = arr[0]
for x in arr:
    
    #comp = int(re.sub('[a-zA-Zㄱ-힗-=+,._#/\?:^$.@*\"※~&%ㆍ!』\\‘|\(\)\[
    # \]\<\>`\'…》]', '', x))
    comp = int(re.sub('[a-zA-Z._/\?:^$.@*\"※~&%ㆍ!』\\‘|\(\)\[''\]\<\>`\'…》]', '', x))
    if(int(comp)==int(prev) and len(x) > len(ret)):
        prev = comp
        ret = x
        
    if(int(comp) > int(prev)):
        prev = comp
        ret = x

print('./' + ret +'/')  

