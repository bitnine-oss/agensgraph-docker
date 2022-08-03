import os

ret = ''
prev = 0
comp = 0
prevstr = ''
size = (os.popen('ls -d */ -l | grep ^d | wc -l')).read()
list = os.popen('ls -d */ -l | awk \'{print $9}\'').read()
arr = list.strip().split('/\n')

ret = arr[0]
for x in arr:
    ##prevstr = x.replace('../..', '')

    comp = int(x.replace('v', '').replace('.','').replace('/',''))
    if(int(comp) > int(prev)):
        prev = comp
        ret = x

print('/' + ret +'/')

