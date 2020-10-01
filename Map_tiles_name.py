
import os

path=os.path.curdir
def list_files(startpath):
    for root, dirs, files in os.walk(startpath):
        d=dirs
        for f in files:
            newname=root+"\\"+f
            newname=newname.replace("\\","_").replace("tiles_","")
            print(newname)
            cp_cmd='copy '+ root.replace("\\","/")+"/" +f +' '+newname
            os.system(cp_cmd.replace("/","\\"))
list_files(path)