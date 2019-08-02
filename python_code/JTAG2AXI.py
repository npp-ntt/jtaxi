from jft import *
from jftsettings import *

def TransToAXIS(group_name, width, flag_last, data):
    if((width>64)|(width<8)):        
        print("TransToAXIS: --------------ERROR! Incorrect width--------------")
        sys.exit()        
    if ((flag_last<0)|(flag_last >1)) :  
        print("TransToAXIS: --------------ERROR! Incorrect flag_last--------------")
        sys.exit()
    DriveGroup(group_name, ((1 << width) | (flag_last << width + 1) | data))


def RecivFromAXIS(group_name, width):
    if((width>64)|(width<8)):        
        print("RecivFromAXIS: --------------ERROR! Incorrect width--------------")
        sys.exit()    
    DriveGroup(group_name, ((1 << width) | ((1 << width + 2))))
    data = GetGroup(group_name)  
    data=bin(data)
    data=data[5:]
    return bit2int(data)

def ResetAXIS(group_name,width):
    if((width>64)|(width<8)):        
        print("ResetAXIS: --------------ERROR! Incorrect width--------------")
        sys.exit()       
    DriveGroup(group_name, 1<<width+1)

def TransToAXIL(group_name,data,addr,SWidth):
    if(addr%4 != 0):
        print("TransToAXIMM: --------------ERROR! Incorrect addr (addr%4 != 0)--------------")
        sys.exit()
    if((SWidth>64)|((SWidth<8)&(SWidth!=0))):        
        print("TransToAXIMM: --------------ERROR! Incorrect SWidth--------------")        
    if(SWidth==0):
        DriveGroup(group_name, ((data<<32)|addr))    
    else:
        DriveGroup(group_name, (((data<<32)|addr)<<SWidth))    
        
def RecivFromAXIL(group_name, addr,SWidth):
    if(addr%4 != 0):
        print("RecivFromAXIMM: --------------ERROR! Incorrect addr (addr%4 != 0)--------------")
        sys.exit()
    if((SWidth>64)|(SWidth<8 & SWidth!=0)):        
        print("RecivFromAXIMM: --------------ERROR! Incorrect SWidth--------------")        
    if(SWidth==0):
        DriveGroup(group_name, ((1<<64)|addr))
        data = GetGroup(group_name);
    else:
        DriveGroup(group_name, ((1<<64)|addr)<<SWidth)
        data = GetGroup(group_name);
    data=bin(data);
    return int(data[3:32+3],2)      

def bit2int(input):
    if (input[0] == '0'):
        #    output=input[1:]
        output = input[1:]
        output = int(output, 2);
    else:
        for i in range(1, len(input)):
            if (input[i] == '0'):
                input = input[:i] + '1' + input[i + 1:]
            else:
                input = input[:i] + '0' + input[i + 1:]
        output = input[1:]
        output = -(int(output, 2) + 1);
    return output         